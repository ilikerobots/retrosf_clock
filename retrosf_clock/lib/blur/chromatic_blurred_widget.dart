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

import 'package:digital_clock/anim/chromatic_flash_glitch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChromaticBlurredWidget extends StatelessWidget {
  final Widget child;
  final double aberrationSize;
  final double sigma;
  final double glitchProbability;

  const ChromaticBlurredWidget({
    Key key,
    this.child,
    this.glitchProbability = 0.5,
    this.aberrationSize = 2.0,
    this.sigma = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: <Widget>[
            ChromaticFlashGlitch(
                effectProbability: this.glitchProbability,
                sigma: 2.0,
                color: Colors.red,
                translateScale: -40.0,
                duration: const Duration(milliseconds: 800),
                child: this.child),
            ChromaticFlashGlitch(
              sigma: 2.0,
              color: Colors.blue,
              translateScale: 25.0,
              effectProbability: this.glitchProbability,
              duration: const Duration(milliseconds: 800),
              child: this.child,
            ),
            Transform.translate(
              offset: Offset(
                  -1.0 * this.aberrationSize, -1.0 * this.aberrationSize),
              child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.red, BlendMode.modulate),
                  child: this.child),
            ),
            Transform.translate(
              offset: Offset(this.aberrationSize, this.aberrationSize),
              child: ColorFiltered(
                  colorFilter:
                      ColorFilter.mode(Colors.blue, BlendMode.modulate),
                  child: this.child),
            ),
            this.child,
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: ColorFiltered(
                  // Make this widget invisible, used only for sizing backdrop filter
                  colorFilter: ColorFilter.mode(Colors.grey, BlendMode.clear),
                  child: this.child),
            ),
          ],
        ),
      ),
    );
  }
}
