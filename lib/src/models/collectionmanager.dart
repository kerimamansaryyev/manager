part of manager;


abstract class CollectionManager<Model> extends Manager<List<Model>>{

  @override
    valueListener(List<Model> newValue){
      _value.addAll(newValue);
      notifyListeners();
    }

  CollectionManager():super(<Model>[]);
}