import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyScreen(),
    );
  }
}

class MyScreen extends StatelessWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text(
              'Health Progressive Bar',
              style: TextStyle(fontSize: 20.0, height: 2),
            ),
            CustomPaint(
              painter: OpenPainter(),
            ),
          ],
        ),
      ),
    );
  }
}

class OpenPainter extends CustomPainter {
  final double _firstCircleRadius = 100;
  final double _secondCircleRadius = 88;
  final double _thirdCircleRadius = 75;
  final double _offsetZero = 0;
  final double _offset150 = 150;
  final double _startAngleDegree = 80;
  final double _sweepAngleDegree = 45;
  final List<int> dash = [6, 6];
  Path outPath = Path();

  //utilities

  //function of changing degrees to radian
  degreeToRadians(num degree) => (degree * math.pi) / 180;

  //interpolation function
  double Function(double input)? interpolate({
    double inputMin = 0,
    double inputMax = 1,
    double outputMin = 0,
    double outputMax = 1,
  }) {
    //range check
    if (inputMin == inputMax) {
      debugPrint('Warning: Zero input range');
      return null;
    }
    if (outputMin == outputMax) {
      debugPrint('Warning: Zero output range');
      return null;
    }
    //check reverse input range
    var reverseInput = false;
    final oldMin = math.min(inputMin, inputMax);
    final oldMax = math.max(inputMin, inputMax);
    if (oldMin != inputMin) {
      reverseInput = true;
    }

    //check reverse output range
    var reverseOutput = false;
    final newMin = math.min(outputMin, outputMax);
    final newMax = math.max(outputMin, outputMax);
    if (newMin != outputMin) {
      reverseInput = true;
    }

    //Hot-rod the most common case
    if (!reverseInput && !reverseOutput) {
      final dNew = newMax - newMin;
      final dOld = oldMax - oldMin;
      return (double x) {
        return ((x - oldMin) * dNew / dOld) + newMin;
      };
    }
    return (double x) {
      double portion;
      if (reverseInput) {
        portion = (oldMax - x) * (newMax - newMin) / (oldMax - oldMin);
      } else {
        portion = (x - oldMin) * (newMax - newMin) / (oldMax - oldMin);
      }
      double result;
      if (reverseOutput) {
        result = newMax - portion;
      } else {
        result = portion + newMax;
      }
      return result;
    };
  }

  //draw label
  void _drawLabel(Canvas canvas, String text,
      {double? fontSize,
      Offset? center,
      Color? color,
      FontWeight? fontWeight,
      String? fontFamily}) {
    final textPainter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.rtl)
      ..text = TextSpan(
          text: text,
          style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontFamily: fontFamily))
      ..layout();
    final bounds = (center! & textPainter.size)
        .translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, bounds.topLeft);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var _firstCirclePaint = Paint()
      ..color = const Color(0xff1d232f)
      ..style = PaintingStyle.fill;
    var _secondCirclePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;
    var _thirdCirclePaint = Paint()
      ..color = const Color(0xff1d232f)
      ..style = PaintingStyle.fill;
    var _arcPaint = Paint()
      ..color = Colors.purple[800]!
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke;

    //first circle
    canvas.drawCircle(
        Offset(_offsetZero, _offset150), _firstCircleRadius, _firstCirclePaint);
    //second circle
    canvas.drawCircle(Offset(_offsetZero, _offset150), _secondCircleRadius,
        _secondCirclePaint);
    //third circle
    canvas.drawCircle(
        Offset(_offsetZero, _offset150), _thirdCircleRadius, _thirdCirclePaint);
    //arc
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(_offsetZero, _offset150),
            radius: (_secondCircleRadius + _thirdCircleRadius) / 2),
        degreeToRadians(_startAngleDegree),
        degreeToRadians(interpolate(
            inputMin: 0,
            inputMax: 100,
            outputMin: 0,
            outputMax: 360)!(_sweepAngleDegree)),
        false,
        _arcPaint);

    //lines
    outPath.addOval(
      Rect.fromCircle(
          center: Offset(_offsetZero, _offset150),
          radius: (_secondCircleRadius + _thirdCircleRadius) / 2.5),
    );

    PathMetrics metrics = outPath.computeMetrics(forceClosed: false);
    Path drawPath = Path();

    for (PathMetric me in metrics) {
      double totalLength = me.length;
      int index = -1;

      for (double start = 0; start < totalLength;) {
        double to = start + dash[(++index) % dash.length];
        to = to > totalLength ? totalLength : to;
        bool isEven = index % 2 == 0;
        if (isEven) {
          drawPath.addPath(
              me.extractPath(start, to, startWithMoveTo: true), Offset.zero);
        }
        start = to;
      }
    }

    canvas.drawPath(
        drawPath,
        Paint()
          ..color = Colors.grey[600]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0);

    //labels in the middle
    _drawLabel(canvas, String.fromCharCode(Icons.directions_run.codePoint),
        center: Offset(_offsetZero, 120),
        fontFamily: Icons.check.fontFamily!,
        fontSize: 20,
        color: Colors.purple[700]!,
        fontWeight: FontWeight.bold);
    _drawLabel(canvas, '1,768',
        fontSize: 34,
        center: Offset(_offsetZero, 155),
        color: Colors.white,
        fontWeight: FontWeight.w900);
    _drawLabel(canvas, 'Steps',
        fontSize: 14,
        center: Offset(_offsetZero, 185),
        color: Colors.grey[300]!,
        fontWeight: FontWeight.w400);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
