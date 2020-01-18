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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChromaticBlurredText extends StatelessWidget {
  final Text child;
  final double aberrationSize;
  final double sigma;

  const ChromaticBlurredText({
    Key key,
    this.child,
    this.aberrationSize = 4.0,
    this.sigma = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveTextStyle = child.style;
    if (child.style == null || child.style.inherit)
      effectiveTextStyle = defaultTextStyle.style.merge(child.style);
    if (MediaQuery.boldTextOverride(context))
      effectiveTextStyle = effectiveTextStyle
          .merge(const TextStyle(fontWeight: FontWeight.bold));

    final double wBlur = this.sigma;
    final Offset rOffset =
        Offset(-1.0 * this.aberrationSize, -1 * this.aberrationSize);
    final double rBlur = this.sigma * 3;
    final Offset gOffset = Offset(0, this.aberrationSize);
    final double gBlur = this.sigma * 3;
    final Offset bOffset = Offset(this.aberrationSize, this.aberrationSize);
    final double bBlur = this.sigma * 3;
    final double extraBlur = this.sigma * 5.5;
    const Color rShadow = Color(0xAAFF0000);
    const Color gShadow = Color(0xAA00FF00);
    const Color bShadow = Color(0xAA0000FF);
    const Color extraShadow = Color(0xfcffffff);

    effectiveTextStyle =
        effectiveTextStyle.merge(TextStyle(color: Color(0x000000), shadows: [
      Shadow(blurRadius: rBlur, color: rShadow, offset: rOffset),
      Shadow(blurRadius: gBlur, color: gShadow, offset: gOffset),
      Shadow(blurRadius: bBlur, color: bShadow, offset: bOffset),
      Shadow(blurRadius: wBlur, color: effectiveTextStyle.color),
      Shadow(blurRadius: extraBlur, color: extraShadow),
    ]));

    return Text(
      child.data,
      key: child.key,
      style: effectiveTextStyle,
      strutStyle: child.strutStyle,
      textAlign: child.textAlign,
      textDirection: child.textDirection,
      locale: child.locale,
      softWrap: child.softWrap,
      overflow: child.overflow,
      textScaleFactor: child.textScaleFactor,
      maxLines: child.maxLines,
      semanticsLabel: child.semanticsLabel,
      textWidthBasis: child.textWidthBasis,
    );
  }
}
