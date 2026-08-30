import 'package:flutter/material.dart';

/// Im Browser gibt es keine Dateipfade - dort liegen die Bilder als Base64
/// in der Erinnerung selbst und dieser Zweig kommt nie zum Zug.
Widget buildFileImage(String path, BoxFit fit, Widget? fallback) =>
    fallback ?? const SizedBox.shrink();
