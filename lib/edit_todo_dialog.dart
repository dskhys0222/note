import 'package:flutter/material.dart';
import 'package:note/todo.dart';

class EditTodoDialog extends StatelessWidget {
  final TextEditingController _textController;

  EditTodoDialog(Todo todo)
      : _textController = TextEditingController(text: todo.name);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit todo'),
      content: TextField(
        controller: _textController,
        autofocus: true,
        onSubmitted: (value) {
          _submit(context);
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            _cancel(context);
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            _submit(context);
          },
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    final String text = _textController.text;
    if (text.isNotEmpty) {
      Navigator.of(context).pop(text);
    }
  }

  void _cancel(BuildContext context) {
    Navigator.of(context).pop();
  }
}
