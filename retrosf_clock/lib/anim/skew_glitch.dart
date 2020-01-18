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

class SkewGlitch extends StatefulWidget {
  SkewGlitch({
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
  _SkewGlitchState createState() => _SkewGlitchState();
}

class _SkewGlitchState extends State<SkewGlitch>
    with
        SingleTickerProviderStateMixin,
        IntermittentControllerRestartStateMixin {
  AnimationController _controller;
  Animation<double> translate;
  Animation<double> skew;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    skew = _skewAnimatable.animate(_controller);

    translate = _translateAnimatable.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.7,
          0.8,
          curve: Curves.slowMiddle,
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

  Animatable<double> get _translateAnimatable {
    return Tween<double>(
      begin: 0.0,
      end: 50, // use scale
    );
  }

  Animatable<double> get _skewAnimatable {
    return new TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.0, end: -0.7)
            .chain(CurveTween(curve: Curves.easeOutExpo)),
        weight: 0.5,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(-0.5),
        weight: 4.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(-0.8),
        weight: 0.5,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(-20),
        weight: 0.5,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(.5),
        weight: 0.1,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(50),
        weight: 0.1,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: 0.1,
      ),
    ]);
  }

  Widget build(BuildContext context) => AnimatedBuilder(
      animation: animationController,
      builder: (context, child) => Transform(
          transform: Matrix4.skewX(skew.value)
            ..translate(translate.value / 2, translate.value),
          alignment: widget.alignment,
          child: child),
      child: widget.child);

  @override
  AnimationController get animationController => _controller;
}
