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

import 'package:digital_clock/intermittent_controller_restart.dart';
import 'package:flutter/widgets.dart';

class RollingVsyncGlitch extends StatefulWidget {
  RollingVsyncGlitch({
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
  _RollingVsyncGlitchState createState() => _RollingVsyncGlitchState();
}

class _RollingVsyncGlitchState extends State<RollingVsyncGlitch>
    with
        SingleTickerProviderStateMixin,
        IntermittentControllerRestartStateMixin {
  AnimationController _controller;
  Animation<double> translate;
  Animation<double> scale;
  Animation<double> skew;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    scale = _scaleAnimatable.animate(_controller);

    translate = _translateAnimatable.animate(_controller);
    skew = _skewAnimatable.animate(_controller);

    doIntermittentControllerRestart(
        checkInterval: widget.checkInterval,
        effectProbability: widget.effectProbability,
        duration: widget.duration);
  }

  Animatable<double> get _translateAnimatable {
    return new TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: 0.1,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.0, end: 50.0)
            .chain(CurveTween(curve: Curves.linear)),
        weight: 5.5,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: -80.0, end: 100.0)
            .chain(CurveTween(curve: Curves.linear)),
        weight: 4.5,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: -80.0, end: 220.0)
            .chain(CurveTween(curve: Curves.linear)),
        weight: 4.5,
      ),
    ]);
  }

  Animatable<double> get _skewAnimatable {
    return new TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: 0.1,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.0, end: 0.1)
            .chain(CurveTween(curve: Curves.easeInSine)),
        weight: 5.5,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.1, end: 0.2)
            .chain(CurveTween(curve: Curves.easeInSine)),
        weight: 4.5,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.2, end: 0.3)
            .chain(CurveTween(curve: Curves.easeInSine)),
        weight: 4.5,
      ),
    ]);
  }

  Animatable<double> get _scaleAnimatable {
    return new TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1),
        weight: 0.1,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 1.0, end: 0.9)
            .chain(CurveTween(curve: Curves.easeOutExpo)),
        weight: 5.5,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.9, end: 0.85)
            .chain(CurveTween(curve: Curves.easeOutExpo)),
        weight: 4.5,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.85, end: 0.8)
            .chain(CurveTween(curve: Curves.easeOutExpo)),
        weight: 4.5,
      ),
    ]);
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
          transform: Matrix4.identity()
            ..translate(1.0, translate.value)
            ..scale(0.999999, scale.value),
          alignment: widget.alignment,
          child: Transform(transform: Matrix4.skewX(skew.value), child: child)),
      child: widget.child);

  @override
  AnimationController get animationController => _controller;
}
