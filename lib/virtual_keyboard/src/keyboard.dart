part of '../vk.dart';

/// The default keyboard height. Can we overriden by passing
///  `height` argument to `VirtualKeyboard` widget.
const double _virtualKeyboardDefaultHeight = 300;

const int _virtualKeyboardBackspaceEventPerioud = 250;

enum VirtualKeyboardType { numeric, alphanumeric, symbolic }

/// Virtual Keyboard widget.
class VirtualKeyboard extends StatefulWidget {
  /// Keyboard Type: Should be inited in creation time.
  final VirtualKeyboardType type;

  /// The text controller
  final TextEditingController textController;

  /// Virtual keyboard height. Default is 300
  final double height;

  /// Color for key texts and icons.
  final Color textColor;

  /// Font size for keyboard keys.
  final double fontSize;

  /// The builder function will be called for each Key object.
  final Widget Function(BuildContext context, VirtualKeyboardKey key)? builder;

  /// Set to true if you want only to show Caps letters.
  final bool alwaysCaps;

  final Function(String)? onSubmitted;

  const VirtualKeyboard({
    required this.type,
    required this.textController,
    super.key,
    this.builder,
    this.height = _virtualKeyboardDefaultHeight,
    this.textColor = Colors.black,
    this.fontSize = 20,
    this.alwaysCaps = false,
    this.onSubmitted,
  });

  @override
  State<StatefulWidget> createState() {
    return _VirtualKeyboardState();
  }
}

/// Holds the state for Virtual Keyboard class.
class _VirtualKeyboardState extends State<VirtualKeyboard> {
  late double keyHeight;
  late double keySpacing;
  late double maxRowWidth;

  VirtualKeyboardType? type;
  // The builder function will be called for each Key object.
  Widget Function(BuildContext context, VirtualKeyboardKey key)? builder;
  late double height;
  late double width;
  TextSelection? cursorPosition;
  late TextEditingController textController;
  late Color textColor;
  late double fontSize;
  late bool alwaysCaps;
  // Text Style for keys.
  late TextStyle textStyle;

  // True if shift is enabled.
  bool isShiftEnabled = false;

  @override
  void didUpdateWidget(VirtualKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      type = widget.type;
      height = widget.height;
      textColor = widget.textColor;
      fontSize = widget.fontSize;
      alwaysCaps = widget.alwaysCaps;

      // Init the Text Style for keys.
      textStyle = TextStyle(
        fontSize: fontSize,
        color: textColor,
      );
    });
  }

  void textControllerEvent() {
    if (textController.selection.toString() != 'TextSelection.invalid') {
      cursorPosition = textController.selection;
    } else {
      if (cursorPosition == null) {
        cursorPosition = const TextSelection(baseOffset: 0, extentOffset: 0);
      } else {}
    }
  }

  @override
  void initState() {
    super.initState();
    textController = widget.textController;
    type = widget.type;
    height = widget.height;
    textColor = widget.textColor;
    fontSize = widget.fontSize;
    alwaysCaps = widget.alwaysCaps;

    textController.addListener(textControllerEvent);

    // Init the Text Style for keys.
    textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      color: textColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    switch (type) {
      case VirtualKeyboardType.numeric:
        return _keyLayout(numericLayout);
      case VirtualKeyboardType.alphanumeric:
        return _keyLayout(usLayout);
      case VirtualKeyboardType.symbolic:
        return _keyLayout(symbolLayout);
      default:
        throw Error();
    }
  }

  Widget _keyLayout(List<List<VirtualKeyboardKey>> layout) {
    // arbritrary
    keySpacing = 8.0;
    final totalSpacing = keySpacing * (layout.length + 1);
    keyHeight = (height - totalSpacing) / layout.length;

    var maxLengthRow = 0;
    for (final layoutRow in layout) {
      if (layoutRow.length > maxLengthRow) {
        maxLengthRow = layoutRow.length;
      }
    }
    maxRowWidth =
        ((maxLengthRow - 1) * keySpacing) + (maxLengthRow * keyHeight);

    return Container(
      height: height,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _rows(layout),
      ),
    );
  }

  /// Returns the rows for keyboard.
  List<Widget> _rows(List<List<VirtualKeyboardKey>> layout) {
    // Generate keyboard row.
    final rows = <Widget>[];
    for (final rowEntry in layout.asMap().entries) {
      final rowNum = rowEntry.key;
      final rowKeys = rowEntry.value;

      final cols = <Widget>[];
      for (final colEntry in rowKeys.asMap().entries) {
        final colNum = colEntry.key;
        final virtualKeyboardKey = colEntry.value;
        Widget keyWidget;

        if (builder == null) {
          // Check the key type.
          switch (virtualKeyboardKey.keyType) {
            case VirtualKeyboardKeyType.string:
              // Draw String key.
              keyWidget = _keyboardDefaultKey(virtualKeyboardKey);
              break;
            case VirtualKeyboardKeyType.action:
              // Draw action key.
              keyWidget = _keyboardDefaultActionKey(virtualKeyboardKey);
              break;
          }
        } else {
          // Call the builder function,
          // so the user can specify custom UI for keys.
          keyWidget = builder!(context, virtualKeyboardKey);

          throw 'builder function must return Widget';
        }
        cols.add(keyWidget);

        // space between keys
        if (colNum != rowKeys.length - 1) {
          cols.add(
            SizedBox(
              width: keySpacing,
            ),
          );
        }
      }
      rows.add(
        Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxRowWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // Generate keboard keys
              children: cols,
            ),
          ),
        ),
      );
      // space between rows
      if (rowNum != layout.length - 1) {
        rows.add(
          SizedBox(
            height: keySpacing,
          ),
        );
      }
    }
    return rows;
  }

  // True if long press is enabled.
  late bool longPress;

  /// Creates default UI element for keyboard Key.
  Widget _keyboardDefaultKey(VirtualKeyboardKey key) {
    return Material(
      color: Colors.grey,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: InkWell(
        highlightColor: Colors.blue,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        onTap: () {
          _onKeyPress(key);
        },
        child: Container(
          width: keyHeight,
          height: keyHeight,
          child: Center(
            child: Text(
              alwaysCaps
                  ? key.capsText!
                  : (isShiftEnabled ? key.capsText! : key.text!),
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }

  void _onKeyPress(VirtualKeyboardKey key) {
    if (key.keyType == VirtualKeyboardKeyType.string) {
      final text = textController.text;
      if (cursorPosition == null) {
        textControllerEvent();
      }
      var textBefore0 = text;
      var textAfter0 = '';
      if (cursorPosition!.start <= text.length) {
        textBefore0 = cursorPosition!.textBefore(text);
        textAfter0 = cursorPosition!.textAfter(text);
      }

      textController.text = textBefore0 +
          (isShiftEnabled ? key.capsText! : key.text!) +
          textAfter0;
      textController.selection = TextSelection(
        baseOffset: textBefore0.length + 1,
        extentOffset: textBefore0.length + 1,
      );
    } else if (key.keyType == VirtualKeyboardKeyType.action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.backspace:
          final text = textController.text;
          if (cursorPosition == null) {
            textControllerEvent();
          }
          if (textController.text.isEmpty) {
            return;
          }
          if (cursorPosition!.start == 0) {
            return;
          }

          var textBefore = text;
          var textAfter = '';
          if (cursorPosition!.start <= text.length) {
            textBefore = text.substring(0, cursorPosition!.start - 1);
            textAfter = text.substring(cursorPosition!.start);
          }

          textController.text = textBefore + textAfter;
          textController.selection = TextSelection(
            baseOffset: textBefore.length,
            extentOffset: textBefore.length,
          );
          break;

        case VirtualKeyboardKeyAction.returned:
          widget.onSubmitted?.call(textController.text);
          break;
        case VirtualKeyboardKeyAction.space:
          textController.text += key.text!;
          break;
        case VirtualKeyboardKeyAction.shift:
          break;
        case VirtualKeyboardKeyAction.alpha:
          setState(() {
            type = VirtualKeyboardType.alphanumeric;
          });
          break;
        case VirtualKeyboardKeyAction.symbols:
          setState(() {
            type = VirtualKeyboardType.symbolic;
          });
          break;
        default:
      }
    }
  }

  /// Creates default UI element for keyboard Action Key.
  Widget _keyboardDefaultActionKey(VirtualKeyboardKey key) {
    // Holds the action key widget.
    Widget actionKey;

    // Switch the action type to build action Key widget.
    switch (key.action!) {
      case VirtualKeyboardKeyAction.backspace:
        actionKey = GestureDetector(
          onLongPress: () {
            longPress = true;
            // Start sending backspace key events while longPress is true
            Timer.periodic(
                const Duration(
                  milliseconds: _virtualKeyboardBackspaceEventPerioud,
                ), (timer) {
              if (longPress) {
                _onKeyPress(key);
              } else {
                // Cancel timer.
                timer.cancel();
              }
            });
          },
          onLongPressUp: () {
            // Cancel event loop
            longPress = false;
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Icon(
              Icons.backspace,
              color: textColor,
            ),
          ),
        );
        break;
      case VirtualKeyboardKeyAction.shift:
        actionKey = Icon(
          Icons.arrow_upward,
          color: isShiftEnabled ? Colors.lime : textColor,
        );
        break;
      case VirtualKeyboardKeyAction.space:
        actionKey = Icon(Icons.space_bar, color: textColor);
        break;
      case VirtualKeyboardKeyAction.returned:
        actionKey = Icon(
          Icons.keyboard_return,
          color: textColor,
        );
        break;
      case VirtualKeyboardKeyAction.symbols:
        actionKey = Icon(Icons.emoji_symbols, color: textColor);
        break;
      case VirtualKeyboardKeyAction.alpha:
        actionKey = Icon(Icons.sort_by_alpha, color: textColor);
        break;
    }
    final finalKey = Material(
      color: Colors.grey,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        highlightColor: Colors.blue,
        onTap: () {
          if (key.action == VirtualKeyboardKeyAction.shift) {
            if (!alwaysCaps) {
              setState(() {
                isShiftEnabled = !isShiftEnabled;
              });
            }
          }

          _onKeyPress(key);
        },
        child: Container(
          width: keyHeight,
          height: keyHeight,
          child: actionKey,
        ),
      ),
    );

    if (key.willExpand) {
      return Expanded(child: finalKey);
    } else {
      return finalKey;
    }
  }
}
