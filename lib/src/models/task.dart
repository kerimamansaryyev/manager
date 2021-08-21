part of manager;

enum TaskStatus{

  Loading,
  Error,
  Success,
  None
}

class TaskResult<Model>{

  final TaskStatus status;
  final Model? value;
  final Exception? errorTrace;

  TaskResult({this.value, required this.status, this.errorTrace});

}


class Task<Model>{

  final String key;
  late DateTime _creationDate;
  BehaviorSubject<TaskResult<Model?>> _stateController = BehaviorSubject();
  Future<Model> Function() computation;
  Stream<TaskResult<Model?>> get state => _stateController;
  late StreamSubscription _subscriptionToFuture;

  @visibleForTesting
    DateTime get timeStamp => _creationDate;
    
  void _register(){
    if(!_stateController.isClosed){
       _stateController.add(TaskResult(status: TaskStatus.Loading));
       var _future = Future(()async{
         try {
           var newModel = await computation().timeout(Manager.globalTaskTimeOut);
           return newModel;
         } on TimeoutException catch (_) {
           throw Exception('time exceeded');
         }
       });
       _subscriptionToFuture = _future.asStream().listen(
         (event) {
           if(!_stateController.isClosed)
           _stateController.add(TaskResult<Model>(status: TaskStatus.Success, value: event));
         }
       )..onError((e){
         var trace = e is Exception? e: null;
         print('Error <$e> in Task:<$key>');
         if(!_stateController.isClosed)
         _stateController.add(TaskResult<Model?>(status: TaskStatus.Error, errorTrace: trace));
       });
    }
  }



  Future<void> _cancelInnerFutureSubscription(){
    _stateController.add(TaskResult(status: TaskStatus.Loading));
    return _subscriptionToFuture.cancel();
  }

  Future<void> _destroy()async{
    _stateController.add(TaskResult(status: TaskStatus.None));
    await _subscriptionToFuture.cancel();
    return _stateController.close();
  }

  @override
    bool operator ==(other){
      return other is Task<Model> && hashCode == other.hashCode && other._creationDate.isAtSameMomentAs(_creationDate);
    }
  
  @override
    int get hashCode => key.hashCode;

  Task({required this.computation, required this.key}){
    _creationDate = DateTime.now();
  }

}