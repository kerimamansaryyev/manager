part of manager;

class PaginatedCollectionBuilder<T extends PaginatedManager<Model>, Model> extends StatefulWidget {


  PaginatedCollectionBuilder({
    Key? key,
    this.before = const [],
    this.after = const [],
    this.contentPadding = const EdgeInsets.all(0),
    required this.loaderWidget,
    required this.loadMoreWidget,
    required this.errorWidget,
    required this.errorOnLoadMoreWidget,
    this.scrollPhysics,
    required this.itemBuilder,
    this.pageFactor = 10,
    this.gridDelegate,
    this.filter,
    this.emptyWidget = const SliverToBoxAdapter(),
    this.needbottomSpace = true

  }) 
    : super(key: key);

  final List<Widget> before;
  final List<Widget> after;
  final EdgeInsets contentPadding;
  final Widget loaderWidget;
  final Widget loadMoreWidget;
  final List<Model> Function(List<Model> m)? filter;
  final SliverGridDelegate? gridDelegate;
  final Widget Function(void Function() closure) errorWidget;
  final Widget Function(void Function() closure) errorOnLoadMoreWidget;
  final ScrollPhysics? scrollPhysics;
  final Widget Function(BuildContext context, Model model, int index) itemBuilder;
  final int pageFactor;
  final Widget emptyWidget;
  final bool needbottomSpace;

  @override
  _PaginatedCollectionBuilderState<T,Model> createState() => _PaginatedCollectionBuilderState<T,Model>();
}

class _PaginatedCollectionBuilderState<_T extends PaginatedManager<_Model>, _Model> extends State<PaginatedCollectionBuilder<_T, _Model>> {

  int _page = 1;
  List<_Model> _secretData = [];

  List<_Model> get _data{
    return _secretData;
  }
  set _data(List<_Model> other){
    _secretData = [
      if(widget.filter != null)
        ...widget.filter!([...other])
      else
        ...other
    ];
  }
  
  bool get _isError => _status == TaskStatus.Error;
  StreamSubscription? _channel;
  TaskStatus _status = TaskStatus.Loading;
  bool get isLoading => _status == TaskStatus.Loading;
  bool get _isErrorOnLoadMore => _data.isNotEmpty && _isError;
  bool get _isLoadingMore => _data.isNotEmpty && isLoading;
  late ScrollController controller;

  void addTaskListener()async{
     await delay();
    _channel = Provider.of<_T>(context, listen: false).taskState(_kPaginatedTaskKey).listen((event) async{ 
        if(mounted){
            final newManagerState = event.state;
            final _taskStatus = event.taskResult.status;
            setState(() {
              _status = _taskStatus;
            });
            if(_taskStatus == TaskStatus.Success){
              setState(() {
                _data = [...newManagerState.data];
                _page = newManagerState.page;
                if(_data.isEmpty){
                  controller.jumpTo(1);
                }
              });
            }
        }
    });
  }

  void _scrollListener() {
    if ( (controller.offset >= controller.position.maxScrollExtent)) {
        _loadMore();
    }
  }

  void _loadMore()async{
    if( !isLoading && !_isLoadingMore && !_isError ){
      setState(() {
        Provider.of<_T>(context, listen:  false)._paginate();
      });
    }
  }

  void tryAgain(){
    Provider.of<_T>(context, listen:  false)._paginate();
  }

  void refresh(){
    Provider.of<_T>(context, listen:  false).refresh();
  }

  void initializeData()async{
    setState(() {
      _data = [...Provider.of<_T>(context, listen: false).dataSync.data];
      _page = Provider.of<_T>(context, listen: false).dataSync.page; 
    });
  }


  @override
    void initState(){
      super.initState();
      initializeData();
      controller = ScrollController();
      controller.addListener(_scrollListener);
      addTaskListener();
    }

  @override
    void dispose(){
      _channel?.cancel();
      controller.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: RefreshIndicator(
         onRefresh: ()async{ refresh();},
         child: CustomScrollView(
           physics: isLoading && !_isLoadingMore? NeverScrollableScrollPhysics(): widget.scrollPhysics,
           controller: controller,
           slivers: [

             if(isLoading && _data.isEmpty)
              widget.loaderWidget
             else if(_isError && _data.isEmpty)
              widget.errorWidget(refresh)
             else if(_data.isEmpty)
              widget.emptyWidget
             else if(widget.gridDelegate != null)
             SliverPadding(
               padding: widget.contentPadding,
               sliver: SliverGrid(
                 delegate: SliverChildBuilderDelegate(
                   (_, index) => widget.itemBuilder(context, _data[index], index),
                   childCount: _data.length
                 ), 
                 gridDelegate: widget.gridDelegate!
               ),
             ) 
             else
              SliverPadding(
                padding: widget.contentPadding,
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    List.generate(
                      _data.length, 
                      (index) => widget.itemBuilder(context,_data[index], index)
                    )
                  ),
                ),
              ),
             if(_isLoadingMore)
              widget.loadMoreWidget
             else if(_isErrorOnLoadMore)
              widget.errorOnLoadMoreWidget(tryAgain)
           ]..insertAll(
             0, 
             widget.before
           )..addAll(
             widget.after
           )..addAll([
             if(widget.needbottomSpace)
             SliverToBoxAdapter(
               child: SizedBox(
                 height: (MediaQuery.of(context).size.height*0.1)/2,
               ),
             )
           ]),
         ),
       ),
    );
  }
}