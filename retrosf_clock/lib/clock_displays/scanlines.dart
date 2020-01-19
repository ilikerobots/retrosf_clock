// Copyright 2020 Michael Hoolehan
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

class _ScanLinePainter extends CustomPainter {
  const _ScanLinePainter({
    this.color,
    this.interval,
    this.lineWidth,
  });

  final Color color;
  final double interval;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()..color = color;
    for (double y = 0.0; y <= size.height; y += interval) {
      linePaint.strokeWidth = this.lineWidth;
      canvas.drawLine(Offset(0.0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(_ScanLinePainter oldPainter) {
    return oldPainter.color != color ||
        oldPainter.interval != interval ||
        oldPainter.lineWidth != lineWidth;
  }

  @override
  bool hitTest(Offset position) => false;
}

class ScanLines extends StatelessWidget {
  final double interval;
  final double lineWidth;
  final Color color;
  final Widget child;

  const ScanLines({
    this.color = const Color(0x33FFFFFF),
    this.interval = 20.0,
    this.lineWidth = 2.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _ScanLinePainter(
        color: color,
        interval: interval,
        lineWidth: lineWidth,
      ),
      child: child,
    );
  }
}
