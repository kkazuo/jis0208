<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

This is a Japanese charset converter library for Dart.

You can encode/decode string to bytes with Japanese legacy encodings such as EUC-JP/Shift_JIS.

## Features

- [x] Windows-31J Encode/Decode. (a.k.a. Shift_JIS)
- [x] EUC-JP Encode/Decode.
- [ ] EUC-JP-ms Encode/Decode.
- [ ] CP51932 Encode/Decode.

## Getting started

Install the package from pub.dev.

```shell
dart pub add jis0208
```

Then import the package:

```dart
import 'package:jis0208/jis0208.dart';
```

## Usage

```dart
import 'dart:io';
import 'package:jis0208/jis0208.dart';

void main() {
  var encoded = Windows31JEncoder().convert('祇園精舎の鐘の声');
  stdout.add(encoded);
}
```

It can also be used as a streaming converter in this way:

```dart
await stdin
      .transform(Windows31JDecoder())
      .transform(LineSplitter())
      .forEach((line) => print(line));
```

## Additional information

This work is heavily depends on [WHATWG](https://encoding.spec.whatwg.org).

They says:

> Copyright © WHATWG (Apple, Google, Mozilla, Microsoft). This work is licensed under a Creative Commons Attribution 4.0 International License. To the extent portions of it are incorporated into source code, such portions in the source code are licensed under the BSD 3-Clause License instead.

So, we license this software under the BSD 3-Clause License.

You can find the source code of this library here: https://github.com/kkazuo/jis0208 .

If you found some issues for this library, please file the issue to https://github.com/kkazuo/jis0208/issues .

No form of support will be provided.
However, by discussing together we may be able to find a solution.
