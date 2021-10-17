import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:manager/manager.dart';
import 'package:manager/tests/counter.dart';

void main() {
  

  group('Unit tests', (){
    test('Manager is updated twice: 1st when the task added to the table, the second time: value is updated', () async{
     final counterManager = CounterManager();
     var updateCounter = 0;
     final updateListener = (){
       updateCounter++;
     };
     counterManager.addListener(updateListener);
     await counterManager.incrementTask();
     counterManager.value.listen((value){
       expect(updateCounter, 3);
     });
   });

   test('Any', () async{
     var status = TaskStatus.None;
     var updateCounter = 0;
     final counterManager = CounterManager();
     final shouldUpdateListener = (TaskStatus old, TaskStatus newStatus) => newStatus != old;
     final listenerUpdate = (){
       if(shouldUpdateListener(status, counterManager.statusTable['increment'] ?? TaskStatus.None))
        updateCounter++;
     };
     counterManager.addListener(listenerUpdate);
     await counterManager.incrementTask();
     counterManager.value.listen((value) { 
       expect(updateCounter, 1);
     });
   });

  });
}