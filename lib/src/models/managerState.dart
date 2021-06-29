part of manager;

class ManagerState<Model>{

  final TaskResult<Model?> taskResult;
  final Model state;

  ManagerState({required this.state,required this.taskResult});

}