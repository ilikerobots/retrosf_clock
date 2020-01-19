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

import 'package:flutter/widgets.dart';

import '../intermittent_controller_restart.dart';
import '../blur/chromatic_blurred_widget.dart';

class BinarySidebar extends StatefulWidget {
  const BinarySidebar({
    Key key,
    this.glitchProbability = .1,
    this.scrambleEffectProbability = .9,
    this.rows = 3,
    this.height = 150.0,
  })  : assert(rows > 2),
        assert(height > 0),
        super(key: key);

  final double glitchProbability;
  final double scrambleEffectProbability;
  final double height;
  final int rows;

  @override
  _BinarySidebarState createState() => _BinarySidebarState();
}

class _BinarySidebarState extends State<BinarySidebar>
    with
        SingleTickerProviderStateMixin,
        IntermittentControllerRestartStateMixin {
  final Random _rnd = Random();
  AnimationController _rndStringController;
  Animation<int> rndValue;

  String binaryString;

  @override
  void initState() {
    super.initState();
    _buildString();

    _rndStringController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    final List<int> digits =
        new List<int>.generate((widget.rows - 2) * 2, (i) => i);

    TweenSequence<int> seq = new TweenSequence<int>(digits.map((v) {
      return TweenSequenceItem<int>(
        tween: ConstantTween<int>(v),
        weight: 1.0,
      );
    }).toList());
    rndValue = seq.animate(_rndStringController)
      ..addListener(() {
        final int maxToScramble = 5;
        int actualToScramble = rndValue.value;
        int startScramblePoint = 0;
        if (actualToScramble > maxToScramble) {
          startScramblePoint = actualToScramble - maxToScramble;
          actualToScramble = maxToScramble;
        }
        final int endScramblePoint = startScramblePoint + actualToScramble;
        String rndPart = "";
        for (int i = startScramblePoint; i < endScramblePoint; i++) {
          rndPart =
              rndPart + (_rnd.nextInt(16).toRadixString(16).toUpperCase());
        }
        String newPart = binaryString.substring(0, startScramblePoint);
        String oldPart = binaryString.substring(endScramblePoint);
        setState(() {
          binaryString = newPart + rndPart + oldPart;
        });
      });
    doIntermittentControllerRestart(
        checkInterval: const Duration(seconds: 2),
        effectProbability: widget.scrambleEffectProbability,
        duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    cancelIntermittentAnimationRestart();
    _rndStringController.dispose();
    super.dispose();
  }

  void _buildString() {
    binaryString = "";
    for (int i = 0; i < widget.rows - 2; i++) {
      setState(() {
        binaryString = binaryString +
            _rnd.nextInt(16).toRadixString(16).toUpperCase() +
            _rnd.nextInt(16).toRadixString(16).toUpperCase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> textWidgets = [];

    StrutStyle strut = StrutStyle(leading: .76, forceStrutHeight: true);
    textWidgets.add(new Text("≜"));
    for (int i = 0; i < widget.rows - 2; i++) {
      if (binaryString.length >= i * 2 + 2) {
        textWidgets.add(new Text(
          binaryString.substring(i * 2, i * 2 + 2),
          strutStyle: strut,
        ));
      }
    }
//    textWidgets.add(new Text("≟"));
    return ChromaticBlurredWidget(
      glitchProbability: widget.glitchProbability,
      sigma: 1.3,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 8, 40),
                child: Container(
                    height: widget.height * 1.5,
                    width: 3,
                    color: Color(0x9acccccc))),
          ]),
          Column(children: textWidgets),
        ],
      ),
    );
  }

  @override
  AnimationController get animationController => _rndStringController;
}
