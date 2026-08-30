import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:momento/core/app_info.dart';

/// Die Versionsnummer steht an zwei Orten: in der `pubspec.yaml` (fuer den
/// Build) und als Konstante im Code (fuer die Anzeige in der App). Dieser
/// Test sorgt dafuer, dass beide dasselbe sagen.
void main() {
  test('Die Version im Code stimmt mit der pubspec.yaml überein', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)', multiLine: true)
        .firstMatch(pubspec);

    expect(match, isNotNull, reason: 'In der pubspec.yaml fehlt "version:"');
    expect(
      match!.group(1),
      momentoVersion,
      reason: 'pubspec.yaml und lib/core/app_info.dart sind auseinandergelaufen',
    );
  });
}
