import 'package:flutter/material.dart';
import 'package:manager/manager.dart';

class ManagerSelector<M extends Manager, V> extends StatefulWidget {
  const ManagerSelector({ Key? key, required this.selector, required this.shouldRebuild, required this.onUpdate, required this.builder }) : super(key: key);

  final V Function(BuildContext, M) selector;
  final bool Function(V, V) shouldRebuild;
  final VoidCallback onUpdate;
  final Widget Function(BuildContext, V) builder;

  @override
  _ManagerSelectorState<M, V> createState() => _ManagerSelectorState<M,V>();
}

class _ManagerSelectorState<M extends Manager, V> extends State<ManagerSelector<M, V>> 
  with ManagerObserverMixin<ManagerSelector<M, V>, M, V>
{
  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context, 
      selector(context, manager)
    );
  }

  @override
  V selector(BuildContext context, M someManager) {
    return widget.selector(context, someManager);
  }

  @override
  bool shouldUpdateListener(V oldVal, V newVal) {
    return widget.shouldRebuild(oldVal, newVal);
  }

  @override
  void updateListener() {
    widget.onUpdate();
    if(mounted)
      setState(() {});
  }
}