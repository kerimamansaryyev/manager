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

  void paginate(){
    if( _value.data.length == perPage*_value.page){
       add(
         Task(
           computation: () => computatiion(_value.page+1),
            key: _kPaginatedTaskKey
         )
       );
    }
  }

  void refresh()async{
     await add(
       Task(
         computation: () async => Pagination<Model>(), 
         key: _kPaginatedTaskKey
       )
     );
     await delay();
     paginate();
  }


  @override
    valueListener(newData){
      if(newData.page == 0){
        _value = newData;
      }
      else{
        var length = _value.data.length+newData.data.length;
        _value = Pagination<Model>(
          data: {..._value.data, ...newData.data}, 
          page: max(1, (length/perPage).truncate())
        );
      }
      print(dataSync.data.length);
      notifyListeners();
    }

   PaginatedManager({Pagination<Model>? initialData}):super( initialData ?? Pagination<Model>() ){
     paginate();
   }

}