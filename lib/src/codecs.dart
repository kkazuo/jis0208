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

import 'package:jis0208/jis0208.dart';

/// A [Windows31JCodec] encodes strings to Windows-31J code units (bytes)
/// and decodes Windows-31J code units to strings.
class Windows31JCodec extends Encoding {
  @override
  Converter<List<int>, String> get decoder => Windows31JDecoder();

  @override
  Converter<String, List<int>> get encoder => Windows31JEncoder();

  @override
  String get name => 'windows-31j';
}

/// A [EucJpCodec] encodes strings to EUC-JP code units (bytes)
/// and decodes EUC-JP code units to strings.
class EucJpCodec extends Encoding {
  @override
  Converter<List<int>, String> get decoder => EucJpDecoder();

  @override
  Converter<String, List<int>> get encoder => EucJpEncoder();

  @override
  String get name => 'euc-jp';
}
