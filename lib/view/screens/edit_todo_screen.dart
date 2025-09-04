import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_todo_app/model/todo_model.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo? existing;
  const AddEditTodoScreen({super.key, this.existing});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  DateTime? _deadline;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _desc = TextEditingController(text: widget.existing?.description ?? '');
    _deadline = widget.existing?.deadline;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final maxW = 700.0;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(isEdit ? 'Edit Details' : 'Add Details'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _title,
                        decoration: const InputDecoration(
                          labelText: 'Todo Title',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _desc,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Add a description...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Deadline',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event_outlined),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  final now = DateTime.now();
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _deadline ?? now,
                                    firstDate: DateTime(now.year - 1),
                                    lastDate: DateTime(now.year + 5),
                                  );
                                  if (picked != null) {
                                    setState(() => _deadline = picked);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _deadline == null
                                          ? 'mm/dd/yyyy'
                                          : DateFormat.yMd().format(_deadline!),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            if (isEdit) {
                              final updated = widget.existing!.copyWith(
                                title: _title.text.trim(),
                                description:
                                    _desc.text.trim().isEmpty
                                        ? null
                                        : _desc.text.trim(),
                                deadline: _deadline,
                              );
                              Navigator.pop(context, updated);
                            } else {
                              final created = Todo(
                                id: nextId(),
                                title: _title.text.trim(),
                                description:
                                    _desc.text.trim().isEmpty
                                        ? null
                                        : _desc.text.trim(),
                                deadline: _deadline,
                                isDone: false,
                              );
                              Navigator.pop(context, created);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
