import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:todo_refatoracao_baguncado/core/ui/app_root.dart';
import 'package:todo_refatoracao_baguncado/features/todos/domain/entities/todo.dart';
import 'package:todo_refatoracao_baguncado/features/todos/domain/repositories/todo_repository.dart';
import 'package:todo_refatoracao_baguncado/features/todos/presentation/viewmodels/todo_viewmodel.dart';

class _FakeTodoRepository implements TodoRepository {
  @override
  Future<TodoFetchResult> fetchTodos({bool forceRefresh = false}) async {
    return const TodoFetchResult(todos: [], lastSyncLabel: null);
  }

  @override
  Future<Todo> addTodo(String title) async {
    return Todo(id: 1, title: title, completed: false);
  }

  @override
  Future<void> updateCompleted({required int id, required bool completed}) async {}
}

void main() {
  testWidgets('App smoke test — renders TodosPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => TodoViewModel(_FakeTodoRepository()),
          ),
        ],
        child: const AppRoot(),
      ),
    );

    // Aguarda microtasks / frames (sem rede real)
    await tester.pump();

    // A AppBar com título 'Todos' deve estar visível
    expect(find.text('Todos'), findsOneWidget);
  });
}
