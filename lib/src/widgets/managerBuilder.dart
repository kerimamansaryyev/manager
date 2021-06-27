part of manager;

class TaskObserverBuilder<T extends Manager<Model>, Model> extends StatelessWidget {
  const TaskObserverBuilder({Key? key,required  this.taskKey,required this.builder}) : super(key: key);

  final String taskKey;
  final Widget Function(BuildContext context, TaskStatus status, Model model, void Function() refresh) builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (context, manager, child) {
        return StreamBuilder<TaskResult<Model?>>(
            stream: manager.taskState(taskKey),
            builder: (context, snapshot) {
               final TaskStatus status = snapshot.data?.status ?? TaskStatus.Loading;
               return builder(context, status, manager.dataSync, () => manager.refreshIfError(taskKey));
            },
        );
      },
    );
  }
}