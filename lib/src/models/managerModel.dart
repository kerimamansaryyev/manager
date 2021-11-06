part of manager;

abstract class Manager<Model> extends ChangeNotifier{

  late BehaviorSubject<Model> value;
  late Model _value;

  Model get dataSync => _value;

  Model transformer(Model newModel){
    return newModel;
  }

  Map<String, Task<Model>?> _tasks = {};
  Map<String, StreamSubscription?> _listeners = {};

  Task<Model>? getTaskByKey(String id) =>_tasks[id] == null? null: Task<Model>(
    computation: _tasks[id]!.computation, 
    key: _tasks[id]!.key 
  )
    ?.._stateController = _tasks[id]!._stateController
    .._creationDate = _tasks[id]!._creationDate
    .._subscriptionToFuture = _tasks[id]!._subscriptionToFuture
  ; 

  Stream<TaskResult<Model?>>? taskStateOnly(String key) => _tasks[key]?.state;

  Stream<ManagerState<Model>> taskStateWithLatestValue(String key) => 
    CombineLatestStream.combine2<TaskResult<Model?>, Model, ManagerState<Model>>(
      _tasks[key]?.state ?? Stream.empty(), 
      value, (a, b) => ManagerState(state: b, taskResult: a)
    );

  Future<void> addTask(Task<Model> newTask,{bool shouldStart = true})async{
    try {
      await _tasks[newTask.key]?._cancelInnerFutureSubscription();
      await _listeners[newTask.key]?.cancel();
    } catch (e) {
      print('Error in managers addtask function of $Model: $e');
    }
    if(_tasks[newTask.key] == null){
      _tasks[newTask.key] = newTask;
    }
    else{
      _tasks[newTask.key]!.computation = newTask.computation;
      _tasks[newTask.key]!._creationDate = DateTime.now();
    }
    if(shouldStart){
      _tasks[newTask.key]!._register(); 
      _listeners[newTask.key] = _tasks[newTask.key]!.state.listen((event) {
        listenerCallBack(event, newTask.key);
        if(event.status == TaskStatus.Success && event.value != null)
          value.add(transformer(event.value!));
      });
    }
    notifyListeners();
  }

  Future<void> startTask(String taskID)async{
    if(_tasks[taskID] != null){
      try {
         await _tasks[taskID]?._cancelInnerFutureSubscription();
         await _listeners[taskID]?.cancel();
      } catch (e) {
         print('Error in managers startTask function of $Model: $e');
      }
      _tasks[taskID]!._register(); 
      _tasks[taskID]!._creationDate = DateTime.now();
      _listeners[taskID] = _tasks[taskID]!.state.listen((event) {
        listenerCallBack(event, taskID);
        if(event.status == TaskStatus.Success && event.value != null)
          value.add(transformer(event.value!));
      });
      notifyListeners();
    }
  }

  void refreshIfError(String key)async{
    await _tasks[key]?._cancelInnerFutureSubscription();
    _tasks[key]?._register();
  }

  Stream<Future<void>> _destroy()async*{
    for(var key in _tasks.keys){
      yield Future(()async{
        await _listeners[key]?.cancel();
        await _tasks[key]?._destroy();
        _tasks[key] = null;
        _listeners[key] = null;
      });
    }
  }

  Future<void> destroy()async{
    await for(var process in _destroy()){
      try {
        await process;
      } catch (e) {
      }
    }
    notifyListeners();
  }

  Future<void> destroyTask(String taskId)async{
    await _listeners[taskId]?.cancel();
    await _tasks[taskId]?._destroy();
    _listeners[taskId] = null;
    _tasks[taskId] = null;
    notifyListeners();
  }

  void valueListener(Model newValue){
    _value = newValue;
    notifyListeners();
  }

  void listenerCallBack(TaskResult<Model?> result, String taskKey){}

  static Duration globalTaskTimeOut = Duration(minutes: 1); 

  @override 
    notifyListeners(){
      if(SchedulerBinding.instance != null) 
        return SchedulerBinding.instance?.addPostFrameCallback((timeStamp) => super.notifyListeners());
      else
        return super.notifyListeners();
    }

  Manager(Model initialData): 
  value = BehaviorSubject.seeded(initialData), 
  _value = initialData
  {
    value.listen(valueListener);
  }

}