/*
Copyright (c) 2024, Koga Kazuo <kkazuo@kkazuo.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
* Neither the name of the <organization> nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import 'dart:convert';
import 'dart:typed_data';

import 'package:jis0208/src/jis0208_table.dart';
import 'package:jis0208/src/buffers.dart';

/// EUC-JP charset encoder
class EucJpEncoder extends Converter<String, Uint8List> {
  @override
  Uint8List convert(String input) {
    final buffer = BytesBuilder(copy: false);
    startChunkedConversion(BytesSink(buffer))
      ..add(input)
      ..close();
    return buffer.toBytes();
  }

  @override
  Sink<String> startChunkedConversion(Sink<Uint8List> sink) =>
      _StringConversionSink(sink);
}

class _StringConversionSink extends StringConversionSinkMixin {
  final Sink<Uint8List> _sink;
  final ByteBuffer _buffer;

  _StringConversionSink(this._sink) : _buffer = ByteBuffer(_sink);

  @override
  void add(String input) {
    for (var codepoint in input.runes) {
      if (0 <= codepoint && codepoint <= 0x7F) {
        _buffer.add(codepoint);
        continue;
      }
      if (codepoint == 0xA5) {
        _buffer.add(0x5C);
        continue;
      }
      if (codepoint == 0x203E) {
        _buffer.add(0x7E);
        continue;
      }
      if (0xFF61 <= codepoint && codepoint <= 0xFF9F) {
        _buffer.add(0x8E);
        _buffer.add(codepoint - 0xFF61 + 0xA1);
        continue;
      }
      if (codepoint == 0x2212) {
        codepoint = 0xFF0D;
      }

      final pointer = toJIS[codepoint];
      if (pointer == null || pointer > 8836) {
        // replacement to '?'
        _buffer.add(0x3F);
        continue;
      }

      final lead = pointer ~/ 94 + 0xA1;
      final trail = pointer % 94 + 0xA1;

      _buffer.add(lead);
      _buffer.add(trail);
    }
  }

  @override
  void addSlice(String str, int start, int end, bool isLast) {
    add(str.substring(start, end));
    if (isLast) {
      close();
    }
  }

  @override
  void close() {
    _buffer.close();
    _sink.close();
  }
}
