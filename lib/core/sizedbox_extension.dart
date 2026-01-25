import 'package:flutter/material.dart';

extension SizedboxExtension on num {
  SizedBox get height => SizedBox(height: this.toDouble());
  SizedBox get width => SizedBox(width: this.toDouble());
  SizedBox get size => SizedBox(
        width: this.toDouble(),
        height: this.toDouble(),
      );
}
