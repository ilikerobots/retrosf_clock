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

import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

abstract class IntermittentControllerRestartStateMixin {
  final Random _rnd = Random();
  bool _statusListenerAdded = false;
  bool _cancelled = false;

  void cancelIntermittentAnimationRestart() {
    _cancelled = true;
  }

  _initAnimation() {
    _statusListenerAdded = true;

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reset();
      }
    });
  }

  AnimationController get animationController;

  void doIntermittentControllerRestart({
    Duration duration = const Duration(seconds: 2),
    Duration checkInterval = const Duration(seconds: 1),
    double effectProbability = 0.50,
  }) {
    if (!_statusListenerAdded) {
      _initAnimation();
    }
    double checkVal = _rnd.nextDouble();
    if (checkVal < effectProbability &&
        animationController.status == AnimationStatus.dismissed) {
      if (!_cancelled) {
        animationController.forward();
      }
    }
    if (!_cancelled) {
      Timer(
          checkInterval,
          () => doIntermittentControllerRestart(
              checkInterval: checkInterval,
              effectProbability: effectProbability));
    }
  }
}
