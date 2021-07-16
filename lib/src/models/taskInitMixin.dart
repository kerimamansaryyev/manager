part of manager;

mixin TaskInitMixin<T extends StatefulWidget, M extends Manager> on State<T>{

  void init();
  late M manager;

  @mustCallSuper
  @override
  void initState() { 
    super.initState();
    manager = Provider.of<M>(context, listen: false);
    manager.addListener(init);
  }

  @mustCallSuper
  @override
  void dispose(){
    manager.removeListener(init);
    super.dispose();
  }
}