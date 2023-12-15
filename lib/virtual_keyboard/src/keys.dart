part of '../vk.dart';

/// US keyboard layout
List<List<VirtualKeyboardKey>> usLayout = [
  // Row 1
  [
    TextKey(
      'q',
    ),
    TextKey(
      'w',
    ),
    TextKey(
      'e',
    ),
    TextKey(
      'r',
    ),
    TextKey(
      't',
    ),
    TextKey(
      'y',
    ),
    TextKey(
      'u',
    ),
    TextKey(
      'i',
    ),
    TextKey(
      'o',
    ),
    TextKey(
      'p',
    ),
  ],
  // Row 2
  [
    TextKey(
      'a',
    ),
    TextKey(
      's',
    ),
    TextKey(
      'd',
    ),
    TextKey(
      'f',
    ),
    TextKey(
      'g',
    ),
    TextKey(
      'h',
    ),
    TextKey(
      'j',
    ),
    TextKey(
      'k',
    ),
    TextKey(
      'l',
    ),
  ],
  // Row 3
  [
    ActionKey(VirtualKeyboardKeyAction.shift),
    TextKey(
      'z',
    ),
    TextKey(
      'x',
    ),
    TextKey(
      'c',
    ),
    TextKey(
      'v',
    ),
    TextKey(
      'b',
    ),
    TextKey(
      'n',
    ),
    TextKey(
      'm',
    ),
    ActionKey(VirtualKeyboardKeyAction.backspace),
  ],
  // Row 4
  [
    ActionKey(VirtualKeyboardKeyAction.symbols),
    TextKey(','),
    ActionKey(VirtualKeyboardKeyAction.space),
    TextKey('.'),
    ActionKey(VirtualKeyboardKeyAction.returned),
  ]
];

/// Symbol layout
List<List<VirtualKeyboardKey>> symbolLayout = [
  // Row 1
  [
    TextKey(
      '1',
    ),
    TextKey(
      '2',
    ),
    TextKey(
      '3',
    ),
    TextKey(
      '4',
    ),
    TextKey(
      '5',
    ),
    TextKey(
      '6',
    ),
    TextKey(
      '7',
    ),
    TextKey(
      '8',
    ),
    TextKey(
      '9',
    ),
    TextKey(
      '0',
    ),
  ],
  // Row 2
  [
    TextKey('@'),
    TextKey('#'),
    TextKey(r'$'),
    TextKey('_'),
    TextKey('-'),
    TextKey('+'),
    TextKey('('),
    TextKey(')'),
    TextKey('/'),
  ],
  // Row 3
  [
    TextKey('|'),
    TextKey('*'),
    TextKey('"'),
    TextKey("'"),
    TextKey(':'),
    TextKey(';'),
    TextKey('!'),
    TextKey('?'),
    ActionKey(VirtualKeyboardKeyAction.backspace),
  ],
  // Row 5
  [
    ActionKey(VirtualKeyboardKeyAction.alpha),
    TextKey(','),
    ActionKey(VirtualKeyboardKeyAction.space),
    TextKey('.'),
    ActionKey(VirtualKeyboardKeyAction.returned),
  ]
];

/// numeric keyboard layout
List<List<VirtualKeyboardKey>> numericLayout = [
  // Row 1
  [
    TextKey('1'),
    TextKey('2'),
    TextKey('3'),
  ],
  // Row 1
  [
    TextKey('4'),
    TextKey('5'),
    TextKey('6'),
  ],
  // Row 1
  [
    TextKey('7'),
    TextKey('8'),
    TextKey('9'),
  ],
  // Row 1
  [TextKey('.'), TextKey('0'), ActionKey(VirtualKeyboardKeyAction.backspace)],
];
