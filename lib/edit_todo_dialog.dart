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
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            Navigator.of(context).pop(_textController.text);
          },
        ),
      ],
    );
  }
}
