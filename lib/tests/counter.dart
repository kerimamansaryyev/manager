import 'package:manager/manager.dart';

class CounterManager extends Manager<int>{

  Map<String, TaskStatus> statusTable = {};

  Future<void> incrementTask()async{
    return addTask(
      Task(
        computation: ()async{
          return dataSync+1;
        }, 
        key: 'increment'
      )
    );
  }

  @override
    listenerCallBack(result, key){
      statusTable[key] = result.status;
      notifyListeners();
    }

  CounterManager() : super(0);
}