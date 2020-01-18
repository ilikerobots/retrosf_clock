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
import 'package:flutter/widgets.dart';

class Jittered extends StatefulWidget {
  Jittered({
    @required this.child,
    this.checkInterval = const Duration(seconds: 1),
    this.duration = const Duration(milliseconds: 500),
    this.effectProbability = 0.10,
    this.effectScale = 4.00,
  });

  final double effectProbability;

  final double effectScale;

  final Duration checkInterval;

  final Duration duration;

  @required
  final Widget child;

  @override
  _JitteredState createState() => _JitteredState();
}

class _JitteredState extends State<Jittered>
    with
        SingleTickerProviderStateMixin,
        IntermittentControllerRestartStateMixin {
  final Random _rnd = Random();

  AnimationController _controller;

  Animation<double> translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    translate = _translateAnimatable.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          1.0,
          curve: Curves.easeOutExpo,
        ),
      ),
    );

    doIntermittentControllerRestart(
        checkInterval: widget.checkInterval,
        effectProbability: widget.effectProbability,
        duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    cancelIntermittentAnimationRestart();
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) => AnimatedBuilder(
      animation: animationController,
      builder: (context, child) => Transform.translate(
          offset: Offset(translate.value, translate.value / 4.0), child: child),
      child: widget.child);

  TweenSequence<double> get _translateAnimatable {
    List<double> jitterValues = new List.generate(
        10, (_) => (_rnd.nextDouble() * 2 - 1) * widget.effectScale);

    return TweenSequence<double>(jitterValues.map((v) {
      return TweenSequenceItem<double>(
        tween: ConstantTween<double>(v),
        weight: 1.0,
      );
    }).toList());
  }

  @override
  AnimationController get animationController => _controller;
}
