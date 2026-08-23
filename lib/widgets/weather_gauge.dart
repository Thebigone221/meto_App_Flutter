import 'dart:math' as math;
import 'package:flutter/material.dart';

class WeatherGauge extends StatefulWidget {
  final double progress;
  final bool isComplete;

  const WeatherGauge({
    super.key,
    required this.progress,
    required this.isComplete,
  });

  @override
  State<WeatherGauge> createState() => _WeatherGaugeState();
}

class _WeatherGaugeState extends State<WeatherGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animProgress;
  double _displayProgress = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animProgress = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(WeatherGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _animProgress = Tween<double>(
        begin: _displayProgress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0);
      _animController.addListener(() {
        setState(() {
          _displayProgress = _animProgress.value;
        });
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CloudGauge(
      progress: _displayProgress,
      isComplete: widget.isComplete,
      width: 260,
      height: 220,
    );
  }
}

class CloudGauge extends StatelessWidget {
  final double progress;
  final bool isComplete;
  final double strokeWidth;
  final double width;
  final double height;

  const CloudGauge({
    super.key,
    required this.progress,
    this.isComplete = false,
    this.strokeWidth = 8,
    this.width = 240,
    this.height = 180,
  });

  static Path buildCloudPath(Size size) {
    final sx = size.width / 240;
    final sy = size.height / 200;

    final path = Path();
    path.moveTo(85 * sx, 145 * sy);
    path.quadraticBezierTo(35 * sx, 145 * sy, 35 * sx, 108 * sy);
    path.quadraticBezierTo(35 * sx, 78 * sy, 65 * sx, 72 * sy);
    path.quadraticBezierTo(64 * sx, 38 * sy, 108 * sx, 35 * sy);
    path.quadraticBezierTo(140 * sx, 33 * sy, 154 * sx, 58 * sy);
    path.quadraticBezierTo(186 * sx, 54 * sy, 197 * sx, 86 * sy);
    path.quadraticBezierTo(220 * sx, 90 * sy, 220 * sx, 118 * sy);
    path.quadraticBezierTo(220 * sx, 145 * sy, 190 * sx, 145 * sy);
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
    final inactiveColor = isDark ? const Color(0x40FFFFFF) : const Color(0x33000000);
    final textColor = Theme.of(context).textTheme.headlineMedium?.color ??
        (isDark ? Colors.white : Colors.black87);

    final path = buildCloudPath(Size(width, height));
    final bounds = path.getBounds();

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CloudOutlinePainter(
                progress: progress.clamp(0.0, 1.0),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                strokeWidth: strokeWidth,
                isComplete: isComplete,
                isDark: isDark,
              ),
            ),
          ),
          Positioned(
            left: bounds.left,
            top: bounds.top,
            width: bounds.width,
            height: bounds.height,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(scale: anim, child: child),
                ),
                child: isComplete
                    ? const SizedBox.shrink(key: ValueKey('empty'))
                    : Column(
                        key: const ValueKey('text'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(progress * 100).round()}',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          Text(
                            '%',
                            style: TextStyle(
                              fontSize: 13,
                              color: textColor.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloudOutlinePainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final double strokeWidth;
  final bool isComplete;
  final bool isDark;

  _CloudOutlinePainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.strokeWidth,
    required this.isComplete,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cloudPath = CloudGauge.buildCloudPath(size);

    if (isComplete) {
      _drawSunBehindCloud(canvas, size, cloudPath);
    }

    final bgPaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(cloudPath, bgPaint);

    if (progress > 0.01) {
      final metrics = cloudPath.computeMetrics().toList();
      final totalLength = metrics.fold<double>(0, (sum, m) => sum + m.length);
      final targetLength = totalLength * progress;

      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      double drawnSoFar = 0;
      for (final metric in metrics) {
        if (drawnSoFar >= targetLength) break;
        final remaining = targetLength - drawnSoFar;
        final lengthToDraw = remaining.clamp(0, metric.length).toDouble();
        final extractedPath = metric.extractPath(0, lengthToDraw);
        canvas.drawPath(extractedPath, activePaint);
        drawnSoFar += metric.length;
      }
    }
  }

  void _drawSunBehindCloud(Canvas canvas, Size size, Path cloudPath) {
    final sx = size.width / 240;
    final sy = size.height / 200;

    canvas.save();

    final maskPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      cloudPath,
    );
    canvas.clipPath(maskPath);

    if (isDark) {
      final shadowRadius = 36.0 * sx;
      final shadowCenter = Offset(192 * sx, 62 * sy);
      final shadowMask = Offset(shadowCenter.dx + 14 * sx, shadowCenter.dy - 10 * sy);
      final shadowPaint = Paint()..color = const Color(0x20C0C0D0);
      canvas.drawCircle(shadowCenter, shadowRadius, shadowPaint);
      final shadowCutPaint = Paint()..color = const Color(0xFF10102A);
      canvas.drawCircle(shadowMask, shadowRadius * 0.85, shadowCutPaint);

      final moonRadius = 26.0 * sx;
      final moonCenter = Offset(196 * sx, 58 * sy);
      final moonMask = Offset(moonCenter.dx + 10 * sx, moonCenter.dy - 7 * sy);
      final moonPaint = Paint()..color = const Color(0xFFE0E0E8);
      canvas.drawCircle(moonCenter, moonRadius, moonPaint);
      final cutPaint = Paint()..color = const Color(0xFF10102A);
      canvas.drawCircle(moonMask, moonRadius * 0.82, cutPaint);
    } else {
      final sunRadius = 30.0 * sx;
      final sunCenter = Offset(192 * sx, 62 * sy);

      final glowPaint = Paint()..color = const Color(0x30FFD60A);
      canvas.drawCircle(sunCenter, sunRadius * 1.6, glowPaint);

      final sunPaint = Paint()..color = const Color(0xFFFFD60A);
      canvas.drawCircle(sunCenter, sunRadius, sunPaint);

      final rayPaint = Paint()
        ..color = const Color(0xFFFFD60A)
        ..strokeWidth = 2.5 * sx
        ..strokeCap = StrokeCap.round;

      final innerDist = sunRadius + 5 * sx;
      final outerDist = sunRadius + 18 * sx;

      for (var i = 0; i < 8; i++) {
        final angle = (math.pi * 2 / 8) * i;
        final dx = math.cos(angle);
        final dy = math.sin(angle);

        final start = Offset(
          sunCenter.dx + dx * innerDist,
          sunCenter.dy + dy * innerDist,
        );
        final end = Offset(
          sunCenter.dx + dx * outerDist,
          sunCenter.dy + dy * outerDist,
        );
        canvas.drawLine(start, end, rayPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CloudOutlinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isComplete != isComplete;
  }
}
