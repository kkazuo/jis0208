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

import 'package:jis0208/jis0208.dart';
import 'package:test/test.dart';

void main() {
  // The original test data can be found here.
  // https://blog.natade.net/2018/11/18/shift_jis-cp932-jis漢字水準/
  // Thanks a lot.
  final input = '''
第1水準の漢字　飴愛嬉
第2水準の漢字　發曖巫
第3水準の漢字　俉𡈽圡剝猪鷗
第4水準の漢字　匤樿
IBM拡張文字にある第3水準の漢字　俉猪
IBM拡張文字にある第4水準の漢字　匤
IBM拡張文字にない第3水準の漢字　𡈽圡剝鷗
IBM拡張文字にない第4水準の漢字　𧲸樿
漢字水準外だがIBM拡張内の漢字　髙
漢字水準外かつIBM拡張外の漢字　𠮷
常用漢字　愛剥
新常用漢字　愛曖剝
人名用漢字　嬉巫猪鷗
Shift_JISの非漢字　◆
JIS X 0201　ｱｲｳｴｵ
NEC特殊文字　⑳
NEC特殊文字外のJIS X 0213非漢字　㉑
Unicodeでサロゲートペアが必要な第3水準の漢字　𡈽
Unicodeでサロゲートペアが必要な第4水準の漢字　𧲸
Unicodeで結合文字列処理が必要なJIS X 0213非漢字　カ゚
''';

  group('A group of Windows-31J tests', () {
    final decoder = Windows31JDecoder();
    final encoder = Windows31JEncoder();
    final expected = '''
第1水準の漢字　飴愛嬉
第2水準の漢字　發曖巫
第3水準の漢字　俉???猪?
第4水準の漢字　匤?
IBM拡張文字にある第3水準の漢字　俉猪
IBM拡張文字にある第4水準の漢字　匤
IBM拡張文字にない第3水準の漢字　????
IBM拡張文字にない第4水準の漢字　??
漢字水準外だがIBM拡張内の漢字　髙
漢字水準外かつIBM拡張外の漢字　?
常用漢字　愛剥
新常用漢字　愛曖?
人名用漢字　嬉巫猪?
Shift_JISの非漢字　◆
JIS X 0201　ｱｲｳｴｵ
NEC特殊文字　⑳
NEC特殊文字外のJIS X 0213非漢字　?
Unicodeでサロゲートペアが必要な第3水準の漢字　?
Unicodeでサロゲートペアが必要な第4水準の漢字　?
Unicodeで結合文字列処理が必要なJIS X 0213非漢字　カ?
''';

    setUp(() {
      // Additional setup goes here.
    });

    test('Encode/Decode Round Trip Test', () {
      expect(decoder.convert(encoder.convert(input)), (a) => a == expected);
    });

    Stream<String> bigString(int count) async* {
      for (var i = 0; i < count; i += 1) {
        yield input;
      }
    }

    test('Heavy Load Bench', () async {
      final count = 30000;
      final len = (await bigString(count)
              .transform(encoder)
              .map<List<int>>((event) => event)
              .transform(decoder)
              .fold(StringBuffer(),
                  (previous, element) => previous..write(element)))
          .toString()
          .length;
      expect(len, count * expected.length);
    });
  });

  group('A group of EUC-JP tests', () {
    final decoder = EucJpDecoder();
    final encoder = EucJpEncoder();
    final expected = '''
第1水準の漢字　飴愛嬉
第2水準の漢字　發曖巫
第3水準の漢字　??????
第4水準の漢字　??
IBM拡張文字にある第3水準の漢字　??
IBM拡張文字にある第4水準の漢字　?
IBM拡張文字にない第3水準の漢字　????
IBM拡張文字にない第4水準の漢字　??
漢字水準外だがIBM拡張内の漢字　?
漢字水準外かつIBM拡張外の漢字　?
常用漢字　愛剥
新常用漢字　愛曖?
人名用漢字　嬉巫??
Shift_JISの非漢字　◆
JIS X 0201　ｱｲｳｴｵ
NEC特殊文字　⑳
NEC特殊文字外のJIS X 0213非漢字　?
Unicodeでサロゲートペアが必要な第3水準の漢字　?
Unicodeでサロゲートペアが必要な第4水準の漢字　?
Unicodeで結合文字列処理が必要なJIS X 0213非漢字　カ?
''';

    setUp(() {
      // Additional setup goes here.
    });

    test('Encode/Decode Round Trip Test', () {
      expect(decoder.convert(encoder.convert(input)), (a) => a == expected);
    });

    Stream<String> bigString(int count) async* {
      for (var i = 0; i < count; i += 1) {
        yield input;
      }
    }

    test('Heavy Load Bench', () async {
      final count = 30000;
      final len = (await bigString(count)
              .transform(encoder)
              .map<List<int>>((event) => event)
              .transform(decoder)
              .fold(StringBuffer(),
                  (previous, element) => previous..write(element)))
          .toString()
          .length;
      expect(len, count * expected.length);
    });
  });
}
