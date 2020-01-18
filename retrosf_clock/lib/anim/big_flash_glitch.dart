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

import 'dart:math';

import 'package:digital_clock/intermittent_controller_restart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BigFlashGlitch extends StatefulWidget {
  BigFlashGlitch({
    @required this.child,
    this.checkInterval = const Duration(seconds: 1),
    this.duration = const Duration(seconds: 2),
    this.effectProbability = 0.10,
    this.effectScale = 4.00,
    this.alignment = Alignment.center,
  });

  @required
  final Widget child;

  final double effectProbability;

  final double effectScale;

  final Duration checkInterval;

  final Duration duration;

  final Alignment alignment;

  @override
  _BigFlashGlitchState createState() => _BigFlashGlitchState();
}

class _BigFlashGlitchState extends State<BigFlashGlitch>
    with TickerProviderStateMixin, IntermittentControllerRestartStateMixin {
  AnimationController _controller;
  Animation<double> size;
  Animation<double> opacity;
  Animation<double> translate;

  Color nextColor;
  final _rnd = Random();

  static const possibleColors = [Colors.red, Colors.green, Colors.blue, null];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _controller.addStatusListener((status) {
      // set the color for for next time
      if (status == AnimationStatus.completed) {
        nextColor = possibleColors[_rnd.nextInt(possibleColors.length)];
      }
    });

    size = _sizeAnimatable.animate(_controller);
    opacity = _opacityAnimatable.animate(_controller);
    translate = _translateAnimatable.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.7,
          1.0,
          curve: Curves.easeOutExpo,
        ),
      ),
    );

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
      child: widget.child,
      builder: (context, child) {
        Widget colored;
        double extraOpacity = 1.0;
        if (_controller.isAnimating && nextColor != null) {
          extraOpacity = 0.50;
          colored = ColorFiltered(
              colorFilter: ColorFilter.mode(nextColor, BlendMode.modulate),
              child: child);
        } else {
          colored = child;
        }

        return Stack(children: [
          Transform(
              transform: Matrix4.diagonal3Values(size.value, size.value, 1.0),
              alignment: widget.alignment,
              child: Opacity(
                  opacity: opacity.value * extraOpacity, child: colored)),
          _controller.isAnimating && nextColor != null
              ? widget.child
              : Offstage(),
        ]);
      });

  @override
  AnimationController get animationController => _controller;

  Animatable<double> get _translateAnimatable {
    return TweenSequence([
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: 0.1,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(50 * widget.effectScale),
        weight: 2.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: 2.0,
      ),
    ]);
  }

  Animatable<double> get _opacityAnimatable {
    return TweenSequence([
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1),
        weight: 12,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 1, end: 0.0),
        weight: 0.8,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: .0, end: 1.0),
        weight: 0.8,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 1, end: 0.3),
        weight: 0.8,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: .0, end: 1.0),
        weight: 0.8,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 1, end: 0.3),
        weight: 0.8,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: .0, end: 1.0),
        weight: 2.0,
      ),
    ]);
  }

  Animatable<double> get _sizeAnimatable {
    return TweenSequence([
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1),
        weight: 0.5,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1 + (widget.effectScale - 1.0) / 2),
        weight: 2.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: 2.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1 + (widget.effectScale - 1.0) / 3),
        weight: 2.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1.00 * widget.effectScale),
        weight: 5.5,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0 * widget.effectScale),
        weight: 0.8,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1.00 * widget.effectScale),
        weight: 5.5,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0 * widget.effectScale),
        weight: 0.8,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1.00 * widget.effectScale),
        weight: 0.8,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0 * widget.effectScale),
        weight: 0.8,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1.00 * widget.effectScale),
        weight: 0.8,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0 * widget.effectScale),
        weight: 2.0,
      ),
    ]);
  }
}
