import 'package:flutter/material.dart';

class AddTodoDialog extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Todo'),
      content: TextField(
        controller: _textController,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _textController.text);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
