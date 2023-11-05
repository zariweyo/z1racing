import 'package:flutter/material.dart';
import 'package:z1racing/virtual_keyboard/vk.dart';

class CommonTextfield extends StatefulWidget {
  final String initialText;
  final Function(String)? onSubmitted;

  CommonTextfield({required this.initialText, this.onSubmitted});
  @override
  State<CommonTextfield> createState() => _CommonTextfieldState();
}

class _CommonTextfieldState extends State<CommonTextfield> {
  late TextEditingController controller;
  late FocusNode focusNode;
  bool showKeyboard = false;

  @override
  initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
    focusNode = FocusNode();
    focusNode.addListener(_textFocusChange);
  }

  @override
  dispose() {
    super.dispose();
    focusNode.removeListener(_textFocusChange);
  }

  _textFocusChange() {
    setState(() {
      showKeyboard = focusNode.hasFocus;
    });
  }

  _onSubmitted(String text) {
    widget.onSubmitted?.call(text);
    focusNode.unfocus();
  }

  _textfield() {
    return TextField(
      focusNode: focusNode,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlignVertical: TextAlignVertical.bottom,
      controller: controller,
      onSubmitted: _onSubmitted,
      decoration: InputDecoration(),
      keyboardType: TextInputType.none,
    );
  }

  Widget _keyboard() {
    if (showKeyboard) {
      return Container(
        color: Colors.grey.shade900,
        margin: EdgeInsets.only(top: 10),
        child: VirtualKeyboard(
            height: 200,
            type: VirtualKeyboardType.Alphanumeric,
            onSubmitted: _onSubmitted,
            textController: controller),
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_textfield(), _keyboard()],
    );
  }
}
