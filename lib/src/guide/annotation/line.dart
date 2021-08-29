import 'dart:ui';

import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/scale/scale.dart';

import 'annotation.dart';

class LineAnnotation extends Annotation {
  LineAnnotation({
    this.dim,
    this.variable,
    required this.value,
    this.style,

    int? zIndex,
  }) : super(
    zIndex: zIndex,
  );

  /// The dim where the line stands.
  final int? dim;

  /// The first variable in this dim by default.
  final String? variable;

  /// The variable value where the line stands.
  final dynamic value;

  final StrokeStyle? style;

  @override
  bool operator ==(Object other) =>
    other is LineAnnotation &&
    super == other &&
    dim == other.dim &&
    variable == other.variable &&
    value == other.value &&
    style == other.style;
}

class LineAnnotPainter extends AnnotPainter {
  LineAnnotPainter(
    this.start,
    this.end,
    this.style,
  );

  final Offset start;

  final Offset end;

  final StrokeStyle style;

  @override
  void paint(Canvas canvas) =>
    canvas.drawLine(start, end, style.toPaint());
}

class ArcLineAnnotPainter extends AnnotPainter {
  ArcLineAnnotPainter(
    this.center,
    this.r,
    this.startAngle,
    this.endAngle,
    this.style,
  );

  final Offset center;

  final double r;

  final double startAngle;

  final double endAngle;

  final StrokeStyle style;

  @override
  void paint(Canvas canvas) => canvas.drawArc(
    Rect.fromCircle(center: center, radius: r),
    startAngle,
    endAngle - startAngle,
    false,
    style.toPaint(),
  );
}

class LineAnnotScene extends AnnotScene {
  @override
  int get layer => Layers.lineAnnot;
}

class LineAnnotRenderOp extends AnnotRenderOp<LineAnnotScene> {
  LineAnnotRenderOp(
    Map<String, dynamic> params,
    LineAnnotScene scene,
  ) : super(params, scene);

  @override
  void render() {
    final dim = params['dim'] as int;
    final variable = params['variable'] as String;
    final value = params['value'];
    final style = params['style'] as StrokeStyle;
    final zIndex = params['zIndex'] as int;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final coord = params['coord'] as CoordConv;

    scene
      ..zIndex = zIndex
      ..setRegionClip(coord.region, coord is PolarCoordConv);
    
    final scale = scales[variable]!;
    final position = scale.normalize(scale.convert(value));

    if (coord is PolarCoordConv && coord.getCanvasDim(dim) == 2) {
      scene.painter = ArcLineAnnotPainter(
        coord.center,
        coord.convertRadius(position),
        coord.angles.first,
        coord.angles.last,
        style,
      );
    } else {
      scene.painter = LineAnnotPainter(
        coord.convert(
          dim == 1
            ? Offset(position, 0)
            : Offset(0, position),
        ),
        coord.convert(
          dim == 1 
            ? Offset(position, 1)
            : Offset(1, position),
        ),
        style,
      );
    }
  }
}
