// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:new_todo_app/cubit/auth_cubit.dart';
import 'package:new_todo_app/cubit/todo_bloc.dart';
import 'package:new_todo_app/model/todo_model.dart';
import 'package:new_todo_app/view/screens/edit_todo_screen.dart';
import 'package:new_todo_app/view/widget/todo_title.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  String _query = '';
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final h = mq.height;
    final w = mq.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Todos', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () => context.read<AuthCubit>().logout(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: Colors.black,
            ),
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
          SizedBox(width: w * 0.02),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          children: [
            if (_showSearch)
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.blueAccent,
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueAccent,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
              ),
            if (_showSearch) SizedBox(height: h * 0.015),
            Expanded(
              child: BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  if (state.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    );
                  }

                  final todos =
                      state.todos
                          .where(
                            (t) =>
                                t.title.toLowerCase().contains(_query) ||
                                (t.description ?? '').toLowerCase().contains(
                                  _query,
                                ),
                          )
                          .toList();

                  if (todos.isEmpty) {
                    return const Center(child: Text('No todos yet'));
                  }

                  return ListView.separated(
                    itemCount: todos.length,
                    separatorBuilder: (_, __) => SizedBox(height: h * 0.015),
                    itemBuilder: (context, i) {
                      final t = todos[i];
                      final auth = context.read<AuthCubit>().state;
                      final email = auth is Authenticated ? auth.email : null;

                      return TodoTile(
                        todo: t,
                        onToggle: () {
                          if (email == null) return;
                          context.read<TodoBloc>().add(
                            TodoToggled(email, t.id),
                          );
                        },
                        onDelete: () async {
                          final confirm =
                              await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: const Text('Delete'),
                                      content: const Text(
                                        'Do you want to delete this todo?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed:
                                              () => Navigator.pop(ctx, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                              ) ??
                              false;

                          if (confirm && email != null) {
                            context.read<TodoBloc>().add(
                              TodoDeleted(email, t.id),
                            );
                          }
                        },
                        onTap: () async {
                          if (email == null) return;
                          final updated = await Navigator.push<Todo?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditTodoScreen(existing: t),
                            ),
                          );
                          if (updated != null) {
                            context.read<TodoBloc>().add(
                              TodoUpdated(email, updated),
                            );
                          }
                        },
                        subtitle:
                            t.deadline == null
                                ? null
                                : 'Deadline: ${DateFormat.yMd().format(t.deadline!)}',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, auth) {
          if (auth is! Authenticated) return const SizedBox.shrink();
          final email = auth.email;
          return FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            onPressed: () async {
              final created = await Navigator.push<Todo?>(
                context,
                MaterialPageRoute(builder: (_) => const AddEditTodoScreen()),
              );
              if (created != null) {
                context.read<TodoBloc>().add(TodoAdded(email, created));
              }
            },
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }
}
