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

import 'package:digital_clock/intermittent_controller_restart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChromaticFlashGlitch extends StatefulWidget {
  ChromaticFlashGlitch({
    @required this.child,
    this.checkInterval = const Duration(seconds: 1),
    this.duration = const Duration(seconds: 2),
    this.effectProbability = 0.10,
    this.sigma = 1.00,
    this.color = Colors.blue,
    this.translateScale = 10.0,
  });

  @required
  final Widget child;

  final double effectProbability;

  final Duration checkInterval;

  final Duration duration;
  final double sigma;
  final double translateScale;
  final Color color;

  @override
  _ChromaticFlashGlitchState createState() => _ChromaticFlashGlitchState();
}

class _ChromaticFlashGlitchState extends State<ChromaticFlashGlitch>
    with
        SingleTickerProviderStateMixin,
        IntermittentControllerRestartStateMixin {
  AnimationController _controller;
  Animation<double> size;
  Animation<double> translate;
  Animation<double> opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    translate = _translateAnimatable.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          0.5,
          curve: Curves.easeOutExpo,
        ),
      ),
    );
    opacity = _opacityAnimatable.animate(_controller);

    doIntermittentControllerRestart(
        checkInterval: widget.checkInterval,
        effectProbability: widget.effectProbability,
        duration: widget.duration);
  }

  @override
  void dispose() {
    cancelIntermittentAnimationRestart();
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) => AnimatedBuilder(
      animation: animationController,
      builder: (context, child) => Transform(
            transform: Matrix4.identity()..translate(translate.value),
            child: ClipRect(
              child: Stack(children: [
                Opacity(
                  opacity: opacity.value,
                  child: ColorFiltered(
                    colorFilter:
                        ColorFilter.mode(widget.color, BlendMode.modulate),
                    child: widget.child,
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: widget.sigma, sigmaY: widget.sigma),
                  child: ColorFiltered(
//                           Make this widget invisible, used only for sizing backdrop filter
                      colorFilter:
                          ColorFilter.mode(Colors.white, BlendMode.clear),
                      child: widget.child),
                )
              ]),
            ),
          ),
      child: widget.child);

  @override
  AnimationController get animationController => _controller;

  Animatable<double> get _translateAnimatable {
    return TweenSequence([
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: 0.5,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(.3 * widget.translateScale),
        weight: 4.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1 * widget.translateScale),
        weight: 2.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: 2.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(.3 * widget.translateScale),
        weight: 2.0,
      ),
    ]);
  }

  Animatable<double> get _opacityAnimatable {
    return TweenSequence([
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: 0.1,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1),
        weight: 4.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: 0.3,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(.8),
        weight: 2.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: 0.2,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1),
        weight: 0.2,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(.3),
        weight: 0.2,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1),
        weight: 0.2,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(.3),
        weight: 0.2,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1),
        weight: 0.2,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutExpo)),
        weight: 8.0,
      )
    ]);
  }
}
