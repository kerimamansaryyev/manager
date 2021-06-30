part of manager;

abstract class Manager<Model> extends ChangeNotifier{

  late BehaviorSubject<Model> value;
  late Model _value;

  Model get dataSync => _value;

  Model transformer(Model newModel){
    return newModel;
  }

  Map<String, Task<Model>> _tasks = {};
  Map<String, StreamSubscription> _listeners = {};

  Stream<ManagerState<Model>> taskState(String key) => 
    CombineLatestStream.combine2<TaskResult<Model?>, Model, ManagerState<Model>>(
      _tasks[key]?.state ?? Stream.empty(), 
      value, (a, b) => ManagerState(state: b, taskResult: a)
    );

  Future<void> add(Task<Model> newTask,{bool shouldStart = true})async{
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
    }
    if(shouldStart){
      _tasks[newTask.key]!._register(); 
      _listeners[newTask.key] = _tasks[newTask.key]!.state.listen((event) {
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
      _listeners[taskID] = _tasks[taskID]!.state.listen((event) {
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
  }

  void valueListener(Model newValue){
    _value = newValue;
    notifyListeners();
  }

  Manager(Model initialData): 
  value = BehaviorSubject.seeded(initialData, sync: true), 
  _value = initialData
  {
    value.listen(valueListener);
  }

}