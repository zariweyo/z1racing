import 'package:flutter/material.dart';

class CommonTextfield extends StatefulWidget {
  final String initialText;
  final Function(String)? onSubmitted;
  final int? maxLength;

  const CommonTextfield({
    required this.initialText,
    super.key,
    this.onSubmitted,
    this.maxLength,
  });
  @override
  State<CommonTextfield> createState() => _CommonTextfieldState();
}

class _CommonTextfieldState extends State<CommonTextfield> {
  late TextEditingController controller;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
    focusNode = FocusNode();
  }

  void _onSubmitted(String text) {
    widget.onSubmitted?.call(text);
    focusNode.unfocus();
  }

  Widget _textfield() {
    return TextField(
      focusNode: focusNode,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: const InputDecoration(
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      textAlignVertical: TextAlignVertical.bottom,
      controller: controller,
      onSubmitted: _onSubmitted,
      keyboardType: TextInputType.name,
      maxLength: widget.maxLength,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _textfield();
  }
}
