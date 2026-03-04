import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/ui/app_root.dart';
import 'features/todos/data/repositories/todo_repository_impl.dart';
import 'features/todos/presentation/viewmodels/todo_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TodoViewModel(TodoRepositoryImpl()),
        ),
      ],
      child: const AppRoot(),
    ),
  );
}
