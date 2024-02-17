import 'package:flutter/material.dart';

class AddTodoDialog extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  AddTodoDialog({required String? initialTag}) {
    _tagController.text = initialTag ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Todo'),
      content: SizedBox(
        height: 150,
        child: Column(
          children: [
            SizedBox(
              height: 80,
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'Name'),
                autofocus: true,
                onSubmitted: (value) {
                  _submit(context);
                },
              ),
            ),
            SizedBox(
              height: 60,
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(labelText: 'Tag'),
                onSubmitted: (value) {
                  _submit(context);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _cancel(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _submit(context);
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    final String name = _textController.text;
    final String tag = _tagController.text;
    if (name.isNotEmpty) {
      Navigator.of(context).pop([name, ...tag.split(' ')]);
    }
  }

  void _cancel(BuildContext context) {
    Navigator.of(context).pop();
  }
}
