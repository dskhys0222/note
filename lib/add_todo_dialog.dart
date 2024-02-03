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
        onSubmitted: (value) {
          _submit(context);
        },
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
    final String text = _textController.text;
    if (text.isNotEmpty) {
      Navigator.of(context).pop(text);
    }
  }

  void _cancel(BuildContext context) {
    Navigator.of(context).pop();
  }
}
