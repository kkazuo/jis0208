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

import 'package:jis0208/src/jis0208_table.dart';
import 'package:jis0208/src/buffers.dart';

/// Windows-31J charset decoder
class Windows31JDecoder extends Converter<List<int>, String> {
  final bool _allowMalformed;

  /// Instantiates a new [Windows31JDecoder].
  ///
  /// The optional [allowMalformed] argument defines how [convert] deals with
  /// invalid or unterminated character sequences.
  ///
  /// If it is true, [convert] replaces invalid (or unterminated) character
  /// sequences with the replacement character 0x3F (?).
  /// Otherwise it throws a [FormatException].
  Windows31JDecoder({bool allowMalformed = false})
      : _allowMalformed = allowMalformed;

  @override
  String convert(List<int> input) {
    final sink = StringSink();
    startChunkedConversion(sink)
      ..add(input)
      ..close();
    return sink.inner();
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<String> sink) =>
      _ByteConversionSink(sink, _allowMalformed);
}

class _ByteConversionSink extends ByteConversionSinkBase {
  final bool _allowMalformed;
  final Sink<String> _sink;
  final CharCodeBuffer _buffer;
  int _lead;

  _ByteConversionSink(this._sink, this._allowMalformed)
      : _buffer = CharCodeBuffer(_sink),
        _lead = 0;

  @override
  void add(List<int> chunk) {
    for (final byte in chunk) {
      if (_lead != 0) {
        final lead = _lead;
        _lead = 0;

        final offset = byte <= 0x7F ? 0x40 : 0x41;
        final leadOffset = lead <= 0xA0 ? 0x81 : 0xC1;

        if (0x40 <= byte && byte <= 0x7E || 0x80 <= byte && byte <= 0xFC) {
          final pointer = (lead - leadOffset) * 188 + byte - offset;
          if (8836 <= pointer && pointer <= 10715) {
            // This is interoperable legacy from Windows known as EUDC.
            _buffer.add(0xE000 - 8836 + pointer);
            continue;
          }
          final codepoint = toUnicode[pointer];
          if (codepoint != null) {
            _buffer.add(codepoint);
            continue;
          }
        }
        if (0 <= byte && byte <= 0x7F) {
          _buffer.add(byte);
        } else if (_allowMalformed) {
          _buffer.add(0xFFFD);
        } else {
          throw FormatException('Malformed end of input.');
        }
      } else {
        if (0 <= byte && byte <= 0x80) {
          _buffer.add(byte);
        } else if (0xA1 <= byte && byte <= 0xDF) {
          _buffer.add(0xFF61 - 0xA1 + byte);
        } else if (0x81 <= byte && byte <= 0x9F ||
            0xE0 <= byte && byte <= 0xFC) {
          _lead = byte;
        } else if (_allowMalformed) {
          _buffer.add(0xFFFD);
        } else {
          throw FormatException('Malformed end of input.');
        }
      }
    }
  }

  @override
  void close() {
    if (_lead != 0) {
      _lead = 0;
      if (_allowMalformed) {
        _buffer.add(0xFFFD);
      } else {
        throw FormatException('Malformed end of input.');
      }
    }
    _buffer.close();
    _sink.close();
  }
}
