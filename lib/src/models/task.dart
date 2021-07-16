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
  BehaviorSubject<TaskResult<Model?>> _stateController = BehaviorSubject();
  Future<Model> Function() computation;
  Stream<TaskResult<Model?>> get state => _stateController.stream;
  late StreamSubscription _subscriptionToFuture;

  void _register(){
    print(_stateController.isClosed);
    if(!_stateController.isClosed){
       _stateController.add(TaskResult(status: TaskStatus.Loading));
       _subscriptionToFuture = computation().asStream().listen(
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

  Future<void> _destroy(){
    return _stateController.close();
  }

  @override
    bool operator ==(other){
      return other is Task<Model> && hashCode == other.hashCode;
    }
  
  @override
    int get hashCode => key.hashCode;

  Task({required this.computation, required this.key});

}