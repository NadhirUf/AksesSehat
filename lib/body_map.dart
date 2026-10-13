import 'package:flutter/semantics.dart';
import 'package:flutter/material.dart';
import 'screens.dart';
import 'strings.dart';

/// Gambar tubuh yang bisa diketuk. Kanvas 300 x 630. Bentuk bagian tubuh
/// ditulis sebagai jalur SVG sederhana (M, L, C, Z) untuk sisi kanan pasien
/// (tampak depan: kiri layar). Sisi kiri dibuat dengan mencerminkan x.
class Zone {
  const Zone(this.id, this.d, [this.side]);
  final String id, d;
  final String? side; // 'r' atau 'l'
}

const bodyFront = <Zone>[
  Zone('head', 'M 150 4 C 172 4, 178 22, 177 40 C 176 58, 164 70, 150 70 C 136 70, 124 58, 123 40 C 122 22, 128 4, 150 4 Z'),
  Zone('neck', 'M 139 72 L 161 72 L 164 90 L 136 90 Z'),
  Zone('chest', 'M 104 94 C 124 88, 140 90, 150 92 C 160 90, 176 88, 196 94 C 201 120, 200 160, 194 188 L 106 188 C 100 160, 99 120, 104 94 Z'),
  Zone('abdomen', 'M 107 192 L 193 192 C 196 220, 197 240, 194 262 L 106 262 C 103 240, 104 220, 107 192 Z'),
  Zone('pelvis', 'M 106 266 L 194 266 C 199 284, 194 302, 182 316 C 170 326, 160 332, 150 334 C 140 332, 130 326, 118 316 C 106 302, 101 284, 106 266 Z'),
  Zone('upper_arm_r', 'M 98 96 C 84 94, 72 100, 69 114 L 60 196 L 85 200 L 97 140 Z', 'r'),
  Zone('upper_arm_l', 'M 98 96 C 84 94, 72 100, 69 114 L 60 196 L 85 200 L 97 140 Z', 'l'),
  Zone('forearm_r', 'M 60 204 L 85 208 L 78 300 L 53 296 Z', 'r'),
  Zone('forearm_l', 'M 60 204 L 85 208 L 78 300 L 53 296 Z', 'l'),
  Zone('hand_r', 'M 53 304 L 78 308 C 79 326, 77 344, 72 354 C 64 360, 55 356, 52 346 C 50 332, 51 318, 53 304 Z', 'r'),
  Zone('hand_l', 'M 53 304 L 78 308 C 79 326, 77 344, 72 354 C 64 360, 55 356, 52 346 C 50 332, 51 318, 53 304 Z', 'l'),
  Zone('thigh_r', 'M 114 320 C 126 330, 138 334, 148 338 L 146 428 L 108 428 C 104 390, 106 352, 114 320 Z', 'r'),
  Zone('thigh_l', 'M 114 320 C 126 330, 138 334, 148 338 L 146 428 L 108 428 C 104 390, 106 352, 114 320 Z', 'l'),
  Zone('knee_r', 'M 108 432 L 146 432 L 145 472 L 110 472 Z', 'r'),
  Zone('knee_l', 'M 108 432 L 146 432 L 145 472 L 110 472 Z', 'l'),
  Zone('lowleg_r', 'M 110 476 L 145 476 C 143 520, 141 556, 138 590 L 116 590 C 113 556, 111 520, 110 476 Z', 'r'),
  Zone('lowleg_l', 'M 110 476 L 145 476 C 143 520, 141 556, 138 590 L 116 590 C 113 556, 111 520, 110 476 Z', 'l'),
  Zone('foot_r', 'M 114 594 L 138 594 L 143 616 C 130 622, 114 622, 102 616 Z', 'r'),
  Zone('foot_l', 'M 114 594 L 138 594 L 143 616 C 130 622, 114 622, 102 616 Z', 'l'),
];
const bodyBack = <Zone>[
  Zone('head', 'M 150 4 C 172 4, 178 22, 177 40 C 176 58, 164 70, 150 70 C 136 70, 124 58, 123 40 C 122 22, 128 4, 150 4 Z'),
  Zone('neck', 'M 139 72 L 161 72 L 164 90 L 136 90 Z'),
  Zone('back_up', 'M 104 94 C 124 88, 140 90, 150 92 C 160 90, 176 88, 196 94 C 201 120, 200 160, 194 188 L 106 188 C 100 160, 99 120, 104 94 Z'),
  Zone('back_low', 'M 107 192 L 193 192 C 196 220, 197 240, 194 262 L 106 262 C 103 240, 104 220, 107 192 Z'),
  Zone('buttocks', 'M 106 266 L 194 266 C 199 284, 194 302, 182 316 C 170 326, 160 332, 150 334 C 140 332, 130 326, 118 316 C 106 302, 101 284, 106 266 Z'),
  Zone('upper_arm_r', 'M 98 96 C 84 94, 72 100, 69 114 L 60 196 L 85 200 L 97 140 Z', 'r'),
  Zone('upper_arm_l', 'M 98 96 C 84 94, 72 100, 69 114 L 60 196 L 85 200 L 97 140 Z', 'l'),
  Zone('forearm_r', 'M 60 204 L 85 208 L 78 300 L 53 296 Z', 'r'),
  Zone('forearm_l', 'M 60 204 L 85 208 L 78 300 L 53 296 Z', 'l'),
  Zone('hand_r', 'M 53 304 L 78 308 C 79 326, 77 344, 72 354 C 64 360, 55 356, 52 346 C 50 332, 51 318, 53 304 Z', 'r'),
  Zone('hand_l', 'M 53 304 L 78 308 C 79 326, 77 344, 72 354 C 64 360, 55 356, 52 346 C 50 332, 51 318, 53 304 Z', 'l'),
  Zone('thigh_r', 'M 114 320 C 126 330, 138 334, 148 338 L 146 428 L 108 428 C 104 390, 106 352, 114 320 Z', 'r'),
  Zone('thigh_l', 'M 114 320 C 126 330, 138 334, 148 338 L 146 428 L 108 428 C 104 390, 106 352, 114 320 Z', 'l'),
  Zone('knee_r', 'M 108 432 L 146 432 L 145 472 L 110 472 Z', 'r'),
  Zone('knee_l', 'M 108 432 L 146 432 L 145 472 L 110 472 Z', 'l'),
  Zone('lowleg_r', 'M 110 476 L 145 476 C 143 520, 141 556, 138 590 L 116 590 C 113 556, 111 520, 110 476 Z', 'r'),
  Zone('lowleg_l', 'M 110 476 L 145 476 C 143 520, 141 556, 138 590 L 116 590 C 113 556, 111 520, 110 476 Z', 'l'),
  Zone('foot_r', 'M 114 594 L 138 594 L 143 616 C 130 622, 114 622, 102 616 Z', 'r'),
  Zone('foot_l', 'M 114 594 L 138 594 L 143 616 C 130 622, 114 622, 102 616 Z', 'l'),
];

// Garis penanda anatomi (tulang selangka, tulang rusuk, tulang belakang, dll).
const _lmFront = <String>[
  'M 106 100 C 122 107, 138 105, 148 98',
  'M 112 296 C 126 306, 140 312, 150 326',
  'M 194 100 C 178 107 162 105 152 98',
  'M 188 296 C 174 306 160 312 150 326',
  'M 150 100 L 150 176',
];
const _lmBack = <String>[
  'M 150 92 L 150 262',
  'M 112 108 C 124 104, 138 118, 140 148',
  'M 150 270 L 150 330',
  'M 188 108 C 176 104 162 118 160 148',
];

Path buildPath(String d, {bool mirror = false}) {
  final tk = RegExp(r'[MLCZ]|-?\d+(?:\.\d+)?').allMatches(d).map((m) => m[0]!).toList();
  final p = Path();
  var i = 0;
  double nx() {
    final v = double.parse(tk[i++]);
    return mirror ? 300 - v : v;
  }

  double ny() => double.parse(tk[i++]);
  while (i < tk.length) {
    switch (tk[i++]) {
      case 'M':
        p.moveTo(nx(), ny());
      case 'L':
        p.lineTo(nx(), ny());
      case 'C':
        p.cubicTo(nx(), ny(), nx(), ny(), nx(), ny());
      case 'Z':
        p.close();
    }
  }
  return p;
}

Path zonePath(Zone z, bool back) =>
    buildPath(z.d, mirror: (z.side == 'l' && !back) || (z.side == 'r' && back));

/// Tampak depan: kanan pasien ada di KIRI layar. Tampak belakang: sebaliknya.
class BodyFigure extends StatelessWidget {
  const BodyFigure({super.key, required this.back, required this.selected, required this.onPick});
  final bool back;
  final String? selected;
  final void Function(String id) onPick;

  @override
  Widget build(BuildContext context) {
    final zones = back ? bodyBack : bodyFront;
    final paths = [for (final z in zones) zonePath(z, back)];
    return AspectRatio(
      aspectRatio: 300 / 630,
      child: FittedBox(
        child: SizedBox(
          width: 300,
          height: 630,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) {
              for (var i = zones.length - 1; i >= 0; i--) {
                if (paths[i].contains(d.localPosition)) {
                  onPick(zones[i].id);
                  return;
                }
              }
              // Ketukan sedikit meleset: pilih bagian terdekat (jarak <= 14).
              var best = -1;
              var bestDist = double.infinity;
              for (var i = 0; i < zones.length; i++) {
                final b = paths[i].getBounds().inflate(14);
                if (!b.contains(d.localPosition)) continue;
                final dist = (paths[i].getBounds().center - d.localPosition).distance;
                if (dist < bestDist) {
                  bestDist = dist;
                  best = i;
                }
              }
              if (best >= 0) onPick(zones[best].id);
            },
            child: CustomPaint(
              painter: _FigurePainter(zones, paths, back, selected, onPick),
            ),
          ),
        ),
      ),
    );
  }
}

class _FigurePainter extends CustomPainter {
  _FigurePainter(this.zones, this.paths, this.back, this.selected, this.onPick);
  final List<Zone> zones;
  final List<Path> paths;
  final bool back;
  final String? selected;
  final void Function(String) onPick;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < zones.length; i++) {
      final sel = zones[i].id == selected;
      canvas.drawPath(paths[i], Paint()..color = sel ? kTeal : kTealTint);
      canvas.drawPath(
        paths[i],
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = sel ? 3.5 : 1.8
          ..color = kTeal,
      );
      if (sel) {
        final c = paths[i].getBounds().center;
        final k = (paths[i].getBounds().shortestSide * 0.28).clamp(7.0, 14.0);
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - k, c.dy)
            ..lineTo(c.dx - k * 0.3, c.dy + k * 0.7)
            ..lineTo(c.dx + k, c.dy - k * 0.7),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = Colors.white,
        );
      }
    }
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x660B6F78);
    for (final d in back ? _lmBack : _lmFront) {
      canvas.drawPath(buildPath(d), line);
    }
    if (!back) canvas.drawCircle(const Offset(150, 228), 3.5, line);
  }

  // Pembaca layar (TalkBack) mendapat tombol untuk tiap bagian tubuh.
  @override
  SemanticsBuilderCallback get semanticsBuilder => (size) => [
        for (var i = 0; i < zones.length; i++)
          CustomPainterSemantics(
            key: ValueKey(zones[i].id),
            rect: paths[i].getBounds(),
            properties: SemanticsProperties(
              label: tr('r_${zones[i].id}'),
              button: true,
              selected: zones[i].id == selected,
              onTap: () => onPick(zones[i].id),
            ),
          ),
      ];

  @override
  bool shouldRepaint(_FigurePainter o) => o.selected != selected || o.back != back;

  @override
  bool shouldRebuildSemantics(_FigurePainter o) => o.selected != selected || o.back != back;
}
