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

import 'package:digital_clock/blur/chromatic_blurred_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const ClockRefreshRate = const Duration(seconds: 1);

class ClockTimeSSDisplay extends StatefulWidget {
  const ClockTimeSSDisplay(this.model,
      {this.sigma = 1.5, this.chromaticGlitchProbability = .10});

  final ClockModel model;
  final double sigma;
  final double chromaticGlitchProbability;

  @override
  _ClockTimeSSDisplayState createState() => _ClockTimeSSDisplayState();
}

class _ClockTimeSSDisplayState extends State<
    ClockTimeSSDisplay> //    with SingleTickerProviderStateMixin {

{
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  final numeralToSymbolMap = {
    '0': "⠚",
    '1': '⠁',
    '2': '⠃',
    '3': '⠉',
    '4': '⠙',
    '5': '⠑',
    '6': '⠋',
    '7': '⠛',
    '8': '⠓',
    '9': '⠊',
  };

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(ClockTimeSSDisplay oldWidget) {
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
//    widget.model.dispose();
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
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        ClockRefreshRate - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatString = "ss";
    final numericString = DateFormat(timeFormatString).format(_dateTime);
    final String tens = numericString[0];
    final String ones = numericString[1];

    final bTens = numeralToSymbolMap[tens];
    final bOnes = numeralToSymbolMap[ones];

    final timeString = "$bTens$bOnes";

    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 0.0, 0, 0),
        // blurred text performs much better than blurred widget
        child: ChromaticBlurredText(
            sigma: widget.sigma, aberrationSize: 2.0, child: Text(timeString)),
      ),
    );
  }
}
