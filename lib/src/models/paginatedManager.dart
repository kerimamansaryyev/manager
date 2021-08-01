part of manager;

final delay = () => Future.delayed(Duration(microseconds: 100));

class Pagination<Model>{
  final Set<Model> data;
  final int page;
  Pagination({this.data = const {}, this.page = 0});
}

abstract class PaginatedManager<Model> extends Manager<Pagination<Model>>{

  int get perPage;
  Future<Pagination<Model>> Function(int page) get computatiion;

  void _paginate(){
    if( _value.data.length == perPage*_value.page){
       addTask(
         Task(
           computation: () => computatiion(_value.page+1),
            key: _kPaginatedTaskKey
         )
       );
    }
  }

  void refresh()async{
    value.add(Pagination<Model>());
    await addTask(
      Task(
        computation: () async{
          return Pagination<Model>();
        }, 
        key: _kPaginatedTaskKey
      )
    );
    _paginate();
  }


  @override
    transformer(newData){
      late Pagination<Model> valueCopy = Pagination( data: {..._value.data}, page: _value.page );
      if(newData.page == 0){
        valueCopy = newData;
      }
      else{
        var merged = {...valueCopy.data, ...newData.data};
        valueCopy = Pagination<Model>(
          data: merged, 
          page: max(1, (merged.length/perPage).truncate())
        );
      }
      return valueCopy;
    }

   PaginatedManager({Pagination<Model>? initialData}):super( initialData ?? Pagination<Model>() ){
     refresh();
   }

}