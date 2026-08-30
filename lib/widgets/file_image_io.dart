import 'dart:io';

import 'package:flutter/material.dart';

/// Bild aus einer Datei - auf Android, iOS und Desktop.
Widget buildFileImage(String path, BoxFit fit, Widget? fallback) => Image.file(
      File(path),
      fit: fit,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink(),
    );
