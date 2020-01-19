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
import 'package:digital_clock/anim/rolling_vsync_glitch.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';

import 'package:digital_clock/anim/big_flash_glitch.dart';
import 'package:digital_clock/clock_displays/scanlines.dart';
import 'intermittent_controller_restart.dart';
import 'clock_displays/binary_sidebar.dart';
import 'icons/lofi_scifi_clock_icons.dart';
import 'blur/chromatic_blurred_widget.dart';
import 'clock_displays/clock_time_hh_mm_display.dart';
import 'clock_displays/clock_time_ss_display.dart';

import 'anim/jittered.dart';
import 'anim/skew_glitch.dart';

const EffectMultiplier = 2.5; //0 to disable, 1 for normal, any other multiplier
const EffectProbabilityClockBigFlash = 0.02 * EffectMultiplier;
const EffectProbabilityFullSkew = 0.02 * EffectMultiplier;
const EffectProbabilityJitter = 0.02 * EffectMultiplier;
const EffectProbabilityRollingVSync = 0.02 * EffectMultiplier;
const EffectProbabilityChromaticGlitch = 0.02 * EffectMultiplier;
const EffectProbabilitySidebarScramble = 0.15 * EffectMultiplier;

enum _Element {
  background,
  text,
}

final _lightTheme = {
  _Element.background: Color(0xFF3333FF),
  _Element.text: Colors.white,
};

final _darkTheme = {
  _Element.background: Color(0xFF662266),
  _Element.text: Color(0xAAFFFFFF),
};

class LofiScifiClock extends StatefulWidget {
  const LofiScifiClock(this.model);

  final ClockModel model;

  @override
  _LofiScifiClockState createState() => _LofiScifiClockState();
}

class _LofiScifiClockState
    extends State<LofiScifiClock> //    with SingleTickerProviderStateMixin {

{
  Timer _timer;
  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final offset = 0.0;

    final binaryCounterStyle = TextStyle(
        color: Color(0x00FFFFFF), fontFamily: 'VT323', fontSize: 32.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final clockHeight = constraints.maxHeight;
        final clockWidth = constraints.maxWidth;
        final timeDisplayWidth = clockWidth * 0.75;
        final fontAspectRatio = 1.0 / 3.50; // of widest string "00:00"
        final fontSize = timeDisplayWidth * fontAspectRatio;
        TextStyle defaultStyle = TextStyle(
          color: Color(0xFFFFFFFF),
          fontFamily: 'Orbitron',
          fontSize: fontSize,
        );
        TextStyle secondsStyle = TextStyle(
            color: Color(0xccFFFFFF),
            fontFamily: 'VT323',
            fontSize: fontSize * 0.75);

        Widget weatherStack = Row(children: [
          WeatherIndicator(
              weatherCondition: widget.model.weatherCondition,
              size: fontSize * .65),
          TempIndicator(
            temp: widget.model.temperature,
            high: widget.model.high,
            low: widget.model.low,
            size: fontSize * .65,
            color: colors[_Element.background],
          ),
        ]);

        return ClipRect(
          child: Container(
            color: colors[_Element.background],
            child: Center(
              child: Stack(
                children: <Widget>[
                  ScanLines(
                    // the background
                    // bottom scanlines
                    lineWidth: 3.0,
                    interval: 10.0,
                    color: new Color(0x08FFFFFF),
                    child: Container(
                      decoration: BoxDecoration(
                        // vignette gradient
                        gradient: RadialGradient(
                          stops: [0.0, 1.0],
                          colors: [
                            Color(0x11000000),
                            Color(0x66000000),
                          ],
                        ),
                      ),
                      child: Container(),
                    ),
                  ),
                  Jittered(
                    effectProbability: EffectProbabilityJitter,
                    child: SkewGlitch(
                        effectScale: 1.00,
                        checkInterval: const Duration(milliseconds: 2500),
                        duration: const Duration(milliseconds: 2500),
                        alignment: Alignment.centerLeft,
                        effectProbability: EffectProbabilityFullSkew,
                        child: RollingVsyncGlitch(
                          effectScale: 1.00,
                          duration: const Duration(milliseconds: 2500),
                          alignment: Alignment.centerLeft,
                          effectProbability: EffectProbabilityRollingVSync,
                          child: Stack(children: [
                            Positioned(
                              left: offset + 30,
                              top: offset + 10,
                              child: DefaultTextStyle(
                                style: defaultStyle.merge(
                                    const TextStyle(color: Color(0xfcffffff))),
                                child: BigFlashGlitch(
                                  effectProbability:
                                      EffectProbabilityClockBigFlash,
                                  alignment: Alignment.centerLeft,
                                  effectScale: 1.8,
                                  duration: const Duration(milliseconds: 550),
                                  child: ClockTimeHHMMDisplay(
                                    widget.model,
                                    fontSize: fontSize,
                                    glitchProbability:
                                        EffectProbabilityChromaticGlitch,
                                    sigma: 1.95,
                                  ),
                                ),
                              ),
                            ),
                            DefaultTextStyle(
                              style: secondsStyle,
                              child: Positioned(
                                  right: offset + 05,
                                  bottom: offset - 25,
                                  child: BigFlashGlitch(
                                    effectProbability:
                                        EffectProbabilityClockBigFlash,
                                    alignment: Alignment.bottomRight,
                                    effectScale: 3.0,
                                    duration: const Duration(milliseconds: 550),
                                    child: ClockTimeSSDisplay(
                                      widget.model,
                                      chromaticGlitchProbability:
                                          EffectProbabilityChromaticGlitch,
                                      sigma: 2.55,
                                    ),
                                  )),
                            ),
                            Positioned(
                              bottom: 30,
                              left: 30,
                              child: BigFlashGlitch(
                                alignment: Alignment.bottomLeft,
                                effectProbability:
                                    EffectProbabilityClockBigFlash,
                                effectScale: 2.0,
                                child: weatherStack,
                              ),
                            ),
                            DefaultTextStyle(
                              style: binaryCounterStyle.merge(
                                  const TextStyle(color: Color(0xfaCCCCCC))),
                              child: Positioned(
                                  right: offset + 00,
                                  top: -10,
                                  child: BinarySidebar(
                                    scrambleEffectProbability:
                                        EffectProbabilitySidebarScramble,
                                    height: clockHeight / 2.5,
                                    rows: (clockHeight - 35) ~/ 32.0,
                                    glitchProbability:
                                        EffectProbabilityChromaticGlitch,
                                  )),
                            ),
                          ]),
                        )),
                  ),
                  ScanLines(
                    // top dark scanlines
                    lineWidth: 2.0,
                    interval: 10.0,
                    color: new Color(0x018000000),
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class WeatherIndicator extends StatefulWidget {
  const WeatherIndicator({
    Key key,
    @required this.size,
    this.weatherCondition,
  }) : super(key: key);

  final double size;
  final WeatherCondition weatherCondition;

  @override
  _WeatherIndicatorState createState() => _WeatherIndicatorState();
}

class _WeatherIndicatorState extends State<WeatherIndicator>
    with
        SingleTickerProviderStateMixin,
        IntermittentControllerRestartStateMixin {
  final Random _rnd = Random();

  AnimationController _rndWeatherController;

  Animation<int> rndValue;

  @override
  void initState() {
    super.initState();

    _rndWeatherController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    List<int> weatherChoices =
        new List.generate(10, (_) => (_rnd.nextInt(7) - 1));

    TweenSequence<int> seq = new TweenSequence<int>(weatherChoices.map((v) {
      return TweenSequenceItem<int>(
        tween: ConstantTween<int>(v),
        weight: 1.0,
      );
    }).toList());

    rndValue = seq.animate(_rndWeatherController)
      ..addListener(() {
        if (this.mounted) {
          setState(() {});
        }
      });
    doIntermittentControllerRestart(
        checkInterval: const Duration(seconds: 1),
        effectProbability: .05 * EffectMultiplier,
        duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    cancelIntermittentAnimationRestart();
    _rndWeatherController.dispose();
    super.dispose();
  }

  static IconData _getIconForWeatherCondition(WeatherCondition c) {
    if (c == WeatherCondition.cloudy) {
      return LofiScifiClockIcons.cloud_sun;
    } else if (c == WeatherCondition.foggy) {
      return LofiScifiClockIcons.mist;
    } else if (c == WeatherCondition.rainy) {
      return LofiScifiClockIcons.rain;
    } else if (c == WeatherCondition.snowy) {
      return LofiScifiClockIcons.snowflake;
    } else if (c == WeatherCondition.sunny) {
      return LofiScifiClockIcons.sun;
    } else if (c == WeatherCondition.thunderstorm) {
      return LofiScifiClockIcons.clouds_flash_alt;
    } else if (c == WeatherCondition.windy) {
      return LofiScifiClockIcons.wind;
    } else {
      return Icons.hourglass_empty;
    }
  }

  WeatherCondition _getWeatherConditionByIndex(i) {
    if (i == 0) {
      return WeatherCondition.cloudy;
    } else if (i == 1) {
      return WeatherCondition.foggy;
    } else if (i == 2) {
      return WeatherCondition.rainy;
    } else if (i == 3) {
      return WeatherCondition.snowy;
    } else if (i == 4) {
      return WeatherCondition.sunny;
    } else if (i == 5) {
      return WeatherCondition.thunderstorm;
    } else if (i == 6) {
      return WeatherCondition.windy;
    } else {
      return null;
    }
  }

  IconData _getIcon() {
    if (_rndWeatherController.isAnimating) {
      return _getIconForWeatherCondition(
          _getWeatherConditionByIndex(rndValue.value));
    } else {
      return _getIconForWeatherCondition(widget.weatherCondition);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Color(0xacf0f0f0);
    return ChromaticBlurredWidget(
      sigma: 2.0,
      aberrationSize: -2.0,
      glitchProbability: EffectProbabilityChromaticGlitch,
      child: Container(
          width: widget.size,
          height: widget.size,
          padding: EdgeInsets.all(widget.size * .03),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(widget.size * 0.15)),
          ),
          child: Icon(
            _getIcon(),
            color: color,
            size: widget.size * .65,
          )),
    );
  }

  @override
  AnimationController get animationController => _rndWeatherController;
}

class TempIndicator extends StatefulWidget {
  const TempIndicator({
    Key key,
    @required this.size,
    @required this.temp,
    @required this.high,
    @required this.low,
    this.color = const Color(0xFF000000),
  }) : super(key: key);

  final num temp;
  final num high;
  final num low;
  final double size;
  final Color color;

  @override
  _TempIndicatorState createState() => _TempIndicatorState();
}

class _TempIndicatorState extends State<TempIndicator>
    with
        SingleTickerProviderStateMixin,
        IntermittentControllerRestartStateMixin {
  final Random _rnd = Random();
  AnimationController _rndTempController;

  Animation<double> rndValue;

  @override
  void initState() {
    super.initState();

    _rndTempController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    List<double> vals = new List.generate(5, (_) => (_rnd.nextDouble()));

    TweenSequence<double> seq = new TweenSequence<double>(vals.map((v) {
      return TweenSequenceItem<double>(
        tween: ConstantTween<double>(v),
        weight: 1.0,
      );
    }).toList());

    rndValue = seq.animate(_rndTempController)
      ..addListener(() {
        if (this.mounted) {
          setState(() {});
        }
      });
    doIntermittentControllerRestart(
        checkInterval: const Duration(seconds: 1),
        effectProbability: .05 * EffectMultiplier,
        duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    cancelIntermittentAnimationRestart();
    _rndTempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String displayTemp = this.widget.temp.round().abs().toString();
    if (_rndTempController.isAnimating) {
      displayTemp = (rndValue.value * 99).round().toString();
    }

    final isThreeDigits = displayTemp.length > 2;
    final widgetWidth = isThreeDigits ? widget.size * 1.25 : widget.size;

    final isPositiveTemp = this.widget.temp > 0;
    final isNegativeTemp = this.widget.temp < 0;

    final Color color = Color(0xaccffffff);
    TextStyle defaultStyle = TextStyle(
      color: widget.color,
      fontFamily: 'Orbitron',
      fontSize: .535 * widget.size,
    );
    TextStyle highlowStyle = TextStyle(
      color: Color(0xFFFFFFFF),
      fontFamily: 'Orbitron',
      fontSize: .25 * widget.size,
    );

    return ChromaticBlurredWidget(
      sigma: 1.6,
      aberrationSize: 2.0,
      glitchProbability: EffectProbabilityChromaticGlitch,
      child: Container(
          width: widgetWidth * 2.35,
          height: widget.size,
          padding: EdgeInsets.all(widget.size * .05),
          child: Stack(children: [
            Positioned(
              left: widgetWidth - 2,
              bottom: 5,
              width: widgetWidth,
              height: widget.size,
              child: CustomPaint(
                painter: TempWidgetLinePainter(),
              ),
            ),
            Positioned(
                left: widgetWidth + widgetWidth * .25,
                bottom: 5,
                child: Text(
                  "LO " + widget.low.round().toString(),
                  style: highlowStyle,
                )),
            Positioned(
                left: widgetWidth + widgetWidth * .25,
                top: 0,
                child: new Text(
                  "H I " + widget.high.round().toString(),
                  style: highlowStyle,
                )),
            Container(
                width: widgetWidth,
                height: widget.size,
                padding: EdgeInsets.all(widget.size * .05),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.all(Radius.circular(widget.size * 0.15)),
                ),
                child: Center(child: Text(displayTemp, style: defaultStyle))),
            isNegativeTemp
                ? Positioned(
                    left: widgetWidth / 2.75,
                    bottom: 4,
                    width: widgetWidth / 4,
                    height: widget.size / 8,
                    child: CustomPaint(
                      painter:
                          TempNegativeIndicatorPainter(color: widget.color),
                    ),
                  )
                : Offstage(),
            isPositiveTemp
                ? Positioned(
                    left: widgetWidth / 2.75,
                    bottom: widget.size - widget.size / 8 - 4 - 10,
                    width: widget.size / 4,
                    height: widget.size / 8,
                    child: CustomPaint(
                      painter:
                          TempPositiveIndicatorPainter(color: widget.color),
                    ),
                  )
                : Offstage(),
          ])),
    );
  }

  @override
  AnimationController get animationController => _rndTempController;
}

class TempWidgetLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    var path = Path();
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    path.moveTo(0, .25 * size.height);
    path.lineTo(size.width / 4, .55 * size.height - 5);
    path.lineTo(size.width * 1.1, .55 * size.height - 5);

    path.moveTo(0, .35 * size.height + 2);
    path.lineTo(size.width / 4, size.height + 2);
    path.lineTo(size.width * 1.1, size.height + 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class TempPositiveIndicatorPainter extends CustomPainter {
  TempPositiveIndicatorPainter({this.color = const Color(0xFFFFFF)});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    var path = Path();
    paint.color = color;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 2.0;
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class TempNegativeIndicatorPainter extends CustomPainter {
  TempNegativeIndicatorPainter({this.color = const Color(0xFFFFFF)});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    var path = Path();
    paint.color = color;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 2.0;
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
