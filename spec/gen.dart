import 'dart:io';
import 'dart:convert';

void main() async {
  print('''// @@@ This is generated code. DO NOT EDIT. @@@
//
// Copyright © WHATWG (Apple, Google, Mozilla, Microsoft). This work is licensed under a Creative Commons Attribution 4.0 International License. To the extent portions of it are incorporated into source code, such portions in the source code are licensed under the BSD 3-Clause License instead.
//
// For details on index see the Encoding Standard
// https://encoding.spec.whatwg.org/
//
''');
  print('const toJIS = {');

  final toUnicode = <int, int>{};
  await stdin
      .transform(const Utf8Decoder())
      .transform(const LineSplitter())
      .forEach((line) {
    if (line.startsWith('#') || line.isEmpty) return;

    final elm = line.split('\t');
    final pointer = int.parse(elm[0].trim());
    final codepoint = int.parse(elm[1].trim().substring(2), radix: 16);

    if ([1207, 1208, 1209, 1212, 1213, 1214, 1217, 1218, 1219, 8644]
        .contains(pointer)) return;
    if (8272 <= pointer && pointer <= 8647) return;
    if (10726 <= pointer && pointer <= 10736) return;
    if (10740 <= pointer && pointer <= 10743) return;
    print("  $codepoint: $pointer, // ${elm[2]}");
    toUnicode[pointer] = codepoint;
  });

  print('};');
  print('const toUnicode = {');
  for (final pointer in toUnicode.keys) {
    print('  $pointer: ${toUnicode[pointer]},');
  }
  print('};');
}
