import 'dart:math' as math;
import 'package:flutter/material.dart';

class ExerciseIllustration extends StatelessWidget {
  final String exerciseName;
  final double height;
  final bool compact;
  final bool showHint;

  const ExerciseIllustration({
    super.key,
    required this.exerciseName,
    this.height = 210,
    this.compact = false,
    this.showHint = true,
  });

  static const Map<String, String> _assetMap = {
    'band squat': 'assets/exercises/squat.png',
    'banded squat': 'assets/exercises/squat.png',
    'squat + press': 'assets/exercises/squat.png',
    'squat với dây kháng lực': 'assets/exercises/squat.png',
    'standing row': 'assets/exercises/standing_row.png',
    'seated row': 'assets/exercises/standing_row.png',
    'fast band row': 'assets/exercises/standing_row.png',
    'glute kickback': 'assets/exercises/glute_kickback.png',
    'chest press': 'assets/exercises/chest_press.png',
    'lateral walk': 'assets/exercises/lateral_walk.png',
    'monster walk': 'assets/exercises/lateral_walk.png',
    'dead bug band': 'assets/exercises/core_combo.png',
    'high plank band tap': 'assets/exercises/core_combo.png',
    'band punch': 'assets/exercises/band_punch.png',
    'romanian deadlift': 'assets/exercises/hip_hinge.png',
    'good morning': 'assets/exercises/hip_hinge.png',
    'standing knee drive': 'assets/exercises/knee_drive.png',
    'biceps curl': 'assets/exercises/biceps_curl.png',
    'hip thrust': 'assets/exercises/glute_bridge.png',
    'glute bridge': 'assets/exercises/glute_bridge.png',
    'reverse lunge': 'assets/exercises/reverse_lunge.png',
    'standing abduction': 'assets/exercises/standing_abduction.png',
    'shoulder press': 'assets/exercises/shoulder_press.png',
    'face pull': 'assets/exercises/upper_finishers.png',
    'triceps extension': 'assets/exercises/upper_finishers.png',
  };

  static String? assetFor(String exerciseName) {
    final key = exerciseName.trim().toLowerCase();
    for (final entry in _assetMap.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = assetFor(exerciseName);
    final scheme = Theme.of(context).colorScheme;

    Widget child;
    if (assetPath != null) {
      child = _AssetExerciseImage(
        assetPath: assetPath,
        exerciseName: exerciseName,
        compact: compact,
      );
    } else {
      child = Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primaryContainer, scheme.surfaceContainerHighest],
          ),
          borderRadius: BorderRadius.circular(compact ? 18 : 28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(compact ? 18 : 28),
          child: CustomPaint(
            painter: _ExercisePainter(
              exerciseName: exerciseName,
              bodyColor: scheme.onPrimaryContainer,
              bandColor: scheme.primary,
              accentColor: scheme.secondary,
            ),
          ),
        ),
      );
    }

    if (compact) return SizedBox(height: height, child: child);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: height, width: double.infinity, child: child),
        if (assetPath != null && showHint)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.zoom_in_rounded, size: 16, color: scheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Chạm để xem rõ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AssetExerciseImage extends StatelessWidget {
  final String assetPath;
  final String exerciseName;
  final bool compact;

  const _AssetExerciseImage({
    required this.assetPath,
    required this.exerciseName,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 18 : 28);
    final rawImage = ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => _brokenAssetFallback(context),
      ),
    );

    if (compact) return rawImage;

    final image = Hero(
      tag: 'asset_$assetPath',
      child: rawImage,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _ExerciseGuidePreviewScreen(
              assetPath: assetPath,
              exerciseName: exerciseName,
            ),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.38),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fitness_center, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exerciseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_full, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brokenAssetFallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.broken_image_outlined, size: 42)),
    );
  }
}

class _ExerciseGuidePreviewScreen extends StatelessWidget {
  final String assetPath;
  final String exerciseName;

  const _ExerciseGuidePreviewScreen({
    required this.assetPath,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exerciseName)),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Hero(
                tag: 'asset_$assetPath',
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExercisePainter extends CustomPainter {
  final String exerciseName;
  final Color bodyColor;
  final Color bandColor;
  final Color accentColor;

  _ExercisePainter({
    required this.exerciseName,
    required this.bodyColor,
    required this.bandColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = exerciseName.toLowerCase();
    final p = Paint()
      ..color = bodyColor
      ..strokeWidth = math.max(4, size.width * .018)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final band = Paint()
      ..color = bandColor
      ..strokeWidth = math.max(5, size.width * .024)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final accent = Paint()
      ..color = accentColor.withOpacity(.22)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * .5, size.height * .52), size.shortestSide * .35, accent);

    if (n.contains('squat')) {
      _squat(canvas, size, p, band, press: n.contains('press'));
    } else if (n.contains('row')) {
      _row(canvas, size, p, band, seated: n.contains('seated'));
    } else if (n.contains('kickback')) {
      _kickback(canvas, size, p, band);
    } else if (n.contains('chest press')) {
      _chestPress(canvas, size, p, band);
    } else if (n.contains('lateral walk') || n.contains('monster walk')) {
      _lateralWalk(canvas, size, p, band, monster: n.contains('monster'));
    } else if (n.contains('dead bug')) {
      _deadBug(canvas, size, p, band);
    } else if (n.contains('punch')) {
      _punch(canvas, size, p, band);
    } else if (n.contains('deadlift') || n.contains('good morning')) {
      _hinge(canvas, size, p, band);
    } else if (n.contains('knee drive')) {
      _kneeDrive(canvas, size, p, band);
    } else if (n.contains('biceps')) {
      _curl(canvas, size, p, band);
    } else if (n.contains('plank')) {
      _plank(canvas, size, p, band);
    } else if (n.contains('hip thrust')) {
      _hipThrust(canvas, size, p, band);
    } else if (n.contains('lunge')) {
      _lunge(canvas, size, p, band);
    } else if (n.contains('abduction')) {
      _abduction(canvas, size, p, band);
    } else if (n.contains('shoulder press')) {
      _shoulderPress(canvas, size, p, band);
    } else if (n.contains('face pull')) {
      _facePull(canvas, size, p, band);
    } else if (n.contains('triceps')) {
      _triceps(canvas, size, p, band);
    } else {
      _standing(canvas, size, p, band);
    }

    final label = TextPainter(
      text: TextSpan(
        text: exerciseName,
        style: TextStyle(color: bodyColor.withOpacity(.72), fontWeight: FontWeight.w800, fontSize: size.width * .048),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: size.width * .78);
    label.paint(canvas, Offset((size.width - label.width) / 2, size.height - label.height - 10));
  }

  void _head(Canvas c, Size s, Paint p, double x, double y, [double r = .055]) {
    c.drawCircle(Offset(s.width * x, s.height * y), s.shortestSide * r, p);
  }

  void _line(Canvas c, Size s, Paint p, double x1, double y1, double x2, double y2) {
    c.drawLine(Offset(s.width * x1, s.height * y1), Offset(s.width * x2, s.height * y2), p);
  }

  void _squat(Canvas c, Size s, Paint p, Paint b, {bool press = false}) {
    _head(c, s, p, .5, .2);
    _line(c, s, p, .5, .27, .5, .5);
    _line(c, s, p, .5, .5, .38, .63); _line(c, s, p, .38, .63, .28, .78);
    _line(c, s, p, .5, .5, .62, .63); _line(c, s, p, .62, .63, .72, .78);
    if (press) {
      _line(c, s, p, .5, .34, .38, .18); _line(c, s, p, .38, .18, .36, .07);
      _line(c, s, p, .5, .34, .62, .18); _line(c, s, p, .62, .18, .64, .07);
      _line(c, s, b, .36, .08, .64, .08);
    } else {
      _line(c, s, p, .5, .35, .36, .46); _line(c, s, p, .5, .35, .64, .46);
      _line(c, s, b, .34, .61, .66, .61);
    }
  }

  void _row(Canvas c, Size s, Paint p, Paint b, {bool seated = false}) {
    _head(c, s, p, .45, .22);
    _line(c, s, p, .45, .29, .48, .52);
    if (seated) { _line(c, s, p, .48, .52, .34, .66); _line(c, s, p, .48, .52, .68, .65); }
    else { _line(c, s, p, .48, .52, .4, .79); _line(c, s, p, .48, .52, .58, .79); }
    _line(c, s, p, .47, .36, .58, .43); _line(c, s, p, .58, .43, .68, .38);
    _line(c, s, p, .47, .36, .55, .47); _line(c, s, p, .55, .47, .67, .43);
    _line(c, s, b, .67, .38, .87, .32); _line(c, s, b, .67, .43, .87, .32);
  }

  void _kickback(Canvas c, Size s, Paint p, Paint b) {
    _head(c, s, p, .42, .22); _line(c, s, p, .42, .29, .46, .53);
    _line(c, s, p, .46, .53, .4, .79); _line(c, s, p, .46, .53, .69, .66); _line(c, s, p, .69, .66, .82, .58);
    _line(c, s, p, .45, .38, .3, .47); _line(c, s, p, .45, .38, .58, .47);
    _line(c, s, b, .39, .75, .69, .63);
  }

  void _chestPress(Canvas c, Size s, Paint p, Paint b) {
    _standing(c, s, p, b);
    _line(c, s, p, .5, .35, .65, .35); _line(c, s, p, .65, .35, .82, .35);
    _line(c, s, p, .5, .38, .65, .43); _line(c, s, p, .65, .43, .82, .43);
    _line(c, s, b, .18, .32, .82, .35); _line(c, s, b, .18, .48, .82, .43);
  }

  void _lateralWalk(Canvas c, Size s, Paint p, Paint b, {bool monster = false}) {
    _head(c, s, p, .5, .18); _line(c, s, p, .5, .25, .5, .48);
    _line(c, s, p, .5, .48, .35, .62); _line(c, s, p, .35, .62, .23, .78);
    _line(c, s, p, .5, .48, .65, .61); _line(c, s, p, .65, .61, .79, .76);
    _line(c, s, p, .5, .34, .34, .42); _line(c, s, p, .5, .34, .66, .42);
    _line(c, s, b, .33, .62, .67, .61);
    if (monster) { _line(c, s, b, .28, .75, .75, .73); }
  }

  void _deadBug(Canvas c, Size s, Paint p, Paint b) {
    _head(c, s, p, .24, .55); _line(c, s, p, .31, .55, .55, .55);
    _line(c, s, p, .43, .55, .53, .34); _line(c, s, p, .53, .34, .68, .22);
    _line(c, s, p, .52, .55, .65, .7); _line(c, s, p, .65, .7, .82, .7);
    _line(c, s, p, .38, .53, .32, .34); _line(c, s, p, .32, .34, .22, .2);
    _line(c, s, b, .22, .2, .68, .22);
  }

  void _punch(Canvas c, Size s, Paint p, Paint b) {
    _standing(c, s, p, b); _line(c, s, p, .5, .34, .68, .28); _line(c, s, p, .68, .28, .9, .24);
    _line(c, s, p, .5, .36, .38, .43); _line(c, s, p, .38, .43, .31, .35);
    _line(c, s, b, .18, .38, .88, .24);
  }

  void _hinge(Canvas c, Size s, Paint p, Paint b) {
    _head(c, s, p, .43, .25); _line(c, s, p, .43, .32, .62, .48);
    _line(c, s, p, .62, .48, .54, .78); _line(c, s, p, .62, .48, .7, .78);
    _line(c, s, p, .54, .42, .47, .61); _line(c, s, p, .68, .51, .66, .65);
    _line(c, s, b, .47, .64, .66, .67); _line(c, s, b, .54, .78, .7, .78);
  }

  void _kneeDrive(Canvas c, Size s, Paint p, Paint b) {
    _head(c, s, p, .5, .18); _line(c, s, p, .5, .25, .5, .5);
    _line(c, s, p, .5, .5, .44, .8); _line(c, s, p, .5, .5, .66, .58); _line(c, s, p, .66, .58, .55, .47);
    _line(c, s, p, .5, .33, .34, .43); _line(c, s, p, .5, .33, .66, .42);
    _line(c, s, b, .44, .76, .65, .58);
  }

  void _curl(Canvas c, Size s, Paint p, Paint b) {
    _standing(c, s, p, b); _line(c, s, p, .5, .34, .38, .48); _line(c, s, p, .38, .48, .34, .35);
    _line(c, s, p, .5, .34, .62, .48); _line(c, s, p, .62, .48, .66, .35);
    _line(c, s, b, .34, .35, .66, .35); _line(c, s, b, .35, .76, .65, .76);
  }

  void _plank(Canvas c, Size s, Paint p, Paint b) {
    _head(c, s, p, .25, .42); _line(c, s, p, .32, .43, .62, .53); _line(c, s, p, .62, .53, .83, .67);
    _line(c, s, p, .42, .47, .32, .68); _line(c, s, p, .52, .5, .48, .7);
    _line(c, s, b, .3, .68, .5, .7);
  }

  void _hipThrust(Canvas c, Size s, Paint p, Paint b) {
    _head(c, s, p, .25, .57); _line(c, s, p, .32, .56, .56, .43); _line(c, s, p, .56, .43, .7, .62); _line(c, s, p, .7, .62, .82, .75);
    _line(c, s, p, .56, .43, .45, .72); _line(c, s, p, .45, .72, .31, .78);
    _line(c, s, b, .48, .5, .7, .62);
  }

  void _lunge(Canvas c, Size s, Paint p, Paint b) {
    _head(c, s, p, .48, .17); _line(c, s, p, .48, .24, .48, .5);
    _line(c, s, p, .48, .5, .35, .62); _line(c, s, p, .35, .62, .22, .77);
    _line(c, s, p, .48, .5, .62, .66); _line(c, s, p, .62, .66, .82, .68);
    _line(c, s, p, .48, .33, .34, .43); _line(c, s, p, .48, .33, .62, .43);
    _line(c, s, b, .22, .77, .82, .68);
  }

  void _abduction(Canvas c, Size s, Paint p, Paint b) {
    _head(c, s, p, .48, .18); _line(c, s, p, .48, .25, .48, .51);
    _line(c, s, p, .48, .51, .43, .8); _line(c, s, p, .48, .51, .75, .63);
    _line(c, s, p, .48, .35, .35, .45); _line(c, s, p, .48, .35, .61, .43);
    _line(c, s, b, .42, .75, .72, .61);
  }

  void _shoulderPress(Canvas c, Size s, Paint p, Paint b) {
    _standing(c, s, p, b); _line(c, s, p, .5, .34, .38, .22); _line(c, s, p, .38, .22, .36, .08);
    _line(c, s, p, .5, .34, .62, .22); _line(c, s, p, .62, .22, .64, .08); _line(c, s, b, .36, .08, .64, .08); _line(c, s, b, .36, .76, .64, .76);
  }

  void _facePull(Canvas c, Size s, Paint p, Paint b) {
    _standing(c, s, p, b); _line(c, s, p, .5, .34, .36, .26); _line(c, s, p, .36, .26, .29, .19);
    _line(c, s, p, .5, .34, .64, .26); _line(c, s, p, .64, .26, .71, .19); _line(c, s, b, .29, .19, .9, .22); _line(c, s, b, .71, .19, .9, .22);
  }

  void _triceps(Canvas c, Size s, Paint p, Paint b) {
    _head(c, s, p, .5, .18); _line(c, s, p, .5, .25, .5, .52); _line(c, s, p, .5, .33, .4, .18); _line(c, s, p, .4, .18, .46, .07);
    _line(c, s, p, .5, .33, .6, .18); _line(c, s, p, .6, .18, .54, .07); _line(c, s, p, .5, .52, .42, .79); _line(c, s, p, .5, .52, .58, .79);
    _line(c, s, b, .46, .07, .54, .07); _line(c, s, b, .42, .79, .58, .79);
  }

  void _standing(Canvas c, Size s, Paint p, Paint b) {
    _head(c, s, p, .5, .18); _line(c, s, p, .5, .25, .5, .52); _line(c, s, p, .5, .34, .36, .48); _line(c, s, p, .5, .34, .64, .48);
    _line(c, s, p, .5, .52, .42, .79); _line(c, s, p, .5, .52, .58, .79); _line(c, s, b, .42, .79, .58, .79);
  }

  @override
  bool shouldRepaint(covariant _ExercisePainter oldDelegate) => oldDelegate.exerciseName != exerciseName || oldDelegate.bodyColor != bodyColor || oldDelegate.bandColor != bandColor;
}
