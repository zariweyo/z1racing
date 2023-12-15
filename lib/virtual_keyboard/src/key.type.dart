part of '../vk.dart';

/// Type for virtual keyboard key.
///
/// `Action` - Can be action key - Return, Backspace, etc.
///
/// `String` - Keys that have text value - `Letters`, `Numbers`, `@` `.`
enum VirtualKeyboardKeyType { action, string }

/// Virtual Keyboard key
class VirtualKeyboardKey {
  /// Will the key expand in it's place
  bool willExpand = false;
  String? text;
  String? capsText;
  final VirtualKeyboardKeyType keyType;
  final VirtualKeyboardKeyAction? action;

  VirtualKeyboardKey({
    required this.keyType,
    this.text,
    this.capsText,
    this.action,
  });
}

/// Shorthand for creating a simple text key
class TextKey extends VirtualKeyboardKey {
  TextKey(String text, {String? capsText})
      : super(
          text: text,
          capsText: capsText ?? text.toUpperCase(),
          keyType: VirtualKeyboardKeyType.string,
        );
}

/// Shorthand for creating action keys
class ActionKey extends VirtualKeyboardKey {
  ActionKey(VirtualKeyboardKeyAction action)
      : super(keyType: VirtualKeyboardKeyType.action, action: action) {
    switch (action) {
      case VirtualKeyboardKeyAction.space:
        super.text = ' ';
        super.capsText = ' ';
        super.willExpand = true;
        break;
      case VirtualKeyboardKeyAction.returned:
        super.text = '\n';
        super.capsText = '\n';
        break;
      case VirtualKeyboardKeyAction.backspace:
        super.willExpand = true;
        break;
      default:
        break;
    }
  }
}
