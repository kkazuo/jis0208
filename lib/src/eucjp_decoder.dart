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
import 'package:jis0208/src/jis0212_table.dart' as jis0212;

/// EUC-JP charset decoder
class EucJpDecoder extends Converter<List<int>, String> {
  final bool _allowMalformed;

  /// Instantiates a new [EucJpDecoder].
  ///
  /// The optional [allowMalformed] argument defines how [convert] deals with
  /// invalid or unterminated character sequences.
  ///
  /// If it is true, [convert] replaces invalid (or unterminated) character
  /// sequences with the replacement character 0x3F (?).
  /// Otherwise it throws a [FormatException].
  EucJpDecoder({bool allowMalformed = false})
      : _allowMalformed = allowMalformed;

  @override
  String convert(List<int> input) {
    final buffer = StringBuffer();
    startChunkedConversion(_StringSink(buffer))
      ..add(input)
      ..close();
    return buffer.toString();
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<String> sink) =>
      _ByteConversionSink(sink, _allowMalformed);
}

class _StringSink implements Sink<String> {
  final StringBuffer _buffer;

  _StringSink(this._buffer);

  @override
  void add(String data) {
    _buffer.write(data);
  }

  @override
  void close() {}
}

class _ByteConversionSink extends ByteConversionSinkBase {
  final bool _allowMalformed;
  final Sink<String> _sink;
  int _lead;
  bool _jis0212;

  _ByteConversionSink(this._sink, this._allowMalformed)
      : _lead = 0,
        _jis0212 = false;

  @override
  void add(List<int> chunk) {
    for (final byte in chunk) {
      if (_lead == 0x8E && 0xA1 <= byte && byte <= 0xDF) {
        _lead = 0;
        _sink.add(String.fromCharCode(0xFF61 - 0xA1 + byte));
        continue;
      }
      if (_lead == 0x8F && 0xA1 <= byte && byte <= 0xFE) {
        _jis0212 = true;
        _lead = byte;
        continue;
      }
      if (_lead != 0) {
        final lead = _lead;
        _lead = 0;
        int? codepoint;

        if (0xA1 <= lead && lead <= 0xFE && 0xA1 <= byte && byte <= 0xFE) {
          if (_jis0212) {
            codepoint = jis0212.toUnicode[(lead - 0xA1) * 94 + byte - 0xA1];
          } else {
            codepoint = toUnicode[(lead - 0xA1) * 94 + byte - 0xA1];
          }
        }

        _jis0212 = false;

        if (codepoint != null) {
          _sink.add(String.fromCharCode(codepoint));
          continue;
        }

        if (0 <= byte && byte <= 0x7F) {
          _sink.add(String.fromCharCode(byte));
        } else if (_allowMalformed) {
          _sink.add(String.fromCharCode(0xFFFD));
        } else {
          throw FormatException('Malformed input of byte as $byte.');
        }
      } else {
        if (0 <= byte && byte <= 0x7F) {
          _sink.add(String.fromCharCode(byte));
        } else if (byte == 0x8E ||
            byte == 0x8F ||
            0xA1 <= byte && byte <= 0xFE) {
          _lead = byte;
        } else if (_allowMalformed) {
          _sink.add(String.fromCharCode(0xFFFD));
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
        _sink.add(String.fromCharCode(0xFFFD));
      } else {
        throw FormatException('Malformed end of input.');
      }
    }
    _sink.close();
  }
}
