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

import 'package:digital_clock/blur/chromatic_blurred_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const ClockRefreshRate = const Duration(minutes: 1);

class ClockTimeHHMMDisplay extends StatefulWidget {
  const ClockTimeHHMMDisplay(this.model,
      {this.glitchProbability = .1, this.fontSize = 16.0, this.sigma = 1.5});

  final ClockModel model;
  final double glitchProbability;
  final double fontSize;
  final double sigma;

  @override
  _ClockTimeHHMMDisplayState createState() => _ClockTimeHHMMDisplayState();
}

class _ClockTimeHHMMDisplayState extends State<
        ClockTimeHHMMDisplay> //    with SingleTickerProviderStateMixin {
    with
        TickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  AnimationController clockController;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();

    clockController =
        AnimationController(duration: const Duration(seconds: 10), vsync: this);

    clockController.forward();
  }

  @override
  void didUpdateWidget(ClockTimeHHMMDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    clockController.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute, but make sure to do it at the beginning of each
      // new minute, so that the clock is accurate.
      _timer = Timer(
        ClockRefreshRate -
            Duration(
                seconds: _dateTime.second, milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatString =
        (widget.model.is24HourFormat ? 'HH' : 'hh') + ":mm";
    final timeString = DateFormat(timeFormatString).format(_dateTime);

    final StrutStyle strut = StrutStyle(leading: 0, forceStrutHeight: false);

    final Text t = new Text(timeString, strutStyle: strut);
    return ChromaticBlurredWidget(
        aberrationSize: widget.fontSize * .025,
        glitchProbability: widget.glitchProbability,
        sigma: widget.sigma,
        child: t);
  }
}
