part of manager;

mixin ManagerObserverMixin<T extends StatefulWidget, M extends Manager, V> on State<T>{

  void updateListener();
  void _updateListener(){
    var _newVal = selector(context, Provider.of<M>(context, listen: false));
    if(shouldUpdateListener(_oldVal, _newVal)){
      updateListener();   
    }
    _oldVal = _newVal;
  }

  late M manager;

  V selector(BuildContext context, M someManager);

  late V _oldVal;

  bool shouldUpdateListener(V oldManager, V newManager);

  @mustCallSuper
  @override
  void initState() { 
    super.initState();
    manager = Provider.of<M>(context, listen: false);
    _oldVal = selector(context, Provider.of<M>(context, listen: false));
    manager.addListener(_updateListener);
  }

  @mustCallSuper
  @override
  void dispose(){
    manager.removeListener(_updateListener);
    super.dispose();
  }
}