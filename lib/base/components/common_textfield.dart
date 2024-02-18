import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/button_action.dart';

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
  late String initialText;
  late String currentText;

  @override
  void initState() {
    super.initState();
    initialText = widget.initialText;
    currentText = widget.initialText;
    controller = TextEditingController(text: widget.initialText);
    focusNode = FocusNode();
  }

  void _onSubmitted(String text) {
    setState(() {
      currentText = text;
      initialText = text;
    });
    widget.onSubmitted?.call(text);
    focusNode.unfocus();
  }

  Widget _textfield() {
    return TextField(
      focusNode: focusNode,
      style:
          Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black),
      decoration: InputDecoration(
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        counter: Container(),
      ),
      textAlignVertical: TextAlignVertical.bottom,
      controller: controller,
      onSubmitted: _onSubmitted,
      keyboardType: TextInputType.name,
      maxLength: widget.maxLength,
      onChanged: (newText) {
        setState(() {
          currentText = newText;
        });
      },
    );
  }

  Widget saveButton() {
    return ButtonActions(
      onTap: () {
        _onSubmitted(controller.text);
      },
      child: Text(
        AppLocalizations.of(context)!.save.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: currentText == initialText ? Colors.grey : Colors.black,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white70,
              ),
              child: _textfield(),
            ),
          ),
          saveButton(),
        ],
      ),
    );
  }
}
