import 'package:jis0208/jis0208.dart';

void main() {
  var encoded = Windows31JEncoder().convert('祇園精舎の鐘の声');
  print('encode: $encoded');

  var decoded = Windows31JDecoder().convert(encoded);
  print('decode: $decoded');
}
