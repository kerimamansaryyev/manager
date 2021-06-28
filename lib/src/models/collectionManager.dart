part of manager;

abstract class CollectionManager<Model> extends Manager<Set<Model>>{

  int get perPage;
  int page = 0;
  Future<Set<Model>> Function(int page) get computatiion;

  void paginate(){
    if( _value.length == perPage*page){
       add(
         Task(
           computation: () => computatiion(page+1),
            key: _kPaginatedTaskKey
         )
       );
    }
  }

  void refresh(){
     _value.clear();
     page = 0;
     paginate();
  }


  @override
    valueListener(Set<Model> newSet){
      _value = {...newSet,..._value};
      page = max(1, (_value.length/perPage).truncate());
      notifyListeners();
    }

   CollectionManager():super({}){
     paginate();
   }

}