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

import 'dart:typed_data';

class CharCodeBuffer implements Sink<int> {
  final Sink<String> _sink;
  final Uint16List _buffer;
  final int _max;
  int _index;

  CharCodeBuffer(this._sink, {int bufferSize = 1000})
      : _buffer = Uint16List(bufferSize),
        _max = bufferSize,
        _index = 0;

  @override
  void add(int charCode) {
    if (_max <= _index) {
      _index = 0;
      _sink.add(String.fromCharCodes(_buffer));
    }

    _buffer[_index] = charCode;
    _index += 1;
  }

  @override
  void close() {
    if (0 < _index) {
      final index = _index;
      _index = 0;
      _sink.add(String.fromCharCodes(_buffer.take(index)));
    }
  }
}

class ByteBuffer implements Sink<int> {
  final Sink<Uint8List> _sink;
  Uint8List _buffer;
  final int _max;
  int _index;

  ByteBuffer(this._sink, {int bufferSize = 1000})
      : _buffer = Uint8List(bufferSize),
        _max = bufferSize,
        _index = 0;

  @override
  void add(int byte) {
    if (_max <= _index) {
      _index = 0;
      final buffer = _buffer;
      _buffer = Uint8List(_max);
      _sink.add(buffer);
    }

    _buffer[_index] = byte;
    _index += 1;
  }

  @override
  void close() {
    if (0 < _index) {
      final index = _index;
      _index = 0;
      _sink.add(_buffer.sublist(0, index));
    }
  }
}

class StringSink implements Sink<String> {
  final StringBuffer _buffer;

  StringSink() : _buffer = StringBuffer();

  String inner() => _buffer.toString();

  @override
  void add(String data) {
    _buffer.write(data);
  }

  @override
  void close() {}
}

class BytesSink implements Sink<Uint8List> {
  final BytesBuilder _buffer;

  BytesSink(this._buffer);

  @override
  void add(Uint8List data) {
    _buffer.add(data);
  }

  @override
  void close() {}
}
