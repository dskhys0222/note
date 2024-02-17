import 'package:flutter/material.dart';

class EditTodoDialog extends StatelessWidget {
  final TextEditingController _textController;
  final TextEditingController _tagController;

  EditTodoDialog(String name, String tags)
      : _textController = TextEditingController(text: name),
        _tagController = TextEditingController(text: tags);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit todo'),
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
