library manager;

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:provider/provider.dart';
export 'package:manager/manager.dart' show Manager;
export 'package:manager/src/widgets/manager_selector.dart';
part 'src/models/manager_model.dart';
part 'src/models/task.dart';
part 'src/widgets/manager_builder.dart';
part 'src/models/paginated_manager.dart';
part 'src/widgets/paginated_collection_builder.dart';
part 'src/models/manager_state.dart';
part 'src/models/manager_observer_mixin.dart';

const _kPaginatedTaskKey = 'pagino';
