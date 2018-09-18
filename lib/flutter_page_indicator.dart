library flutter_page_indicator;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class WarmPainter extends BasePainter {
  WarmPainter(PageIndicator widget, double page, int index, Paint paint) : super(widget, page, index, paint);


  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double distance = size + space;
    double start = index * (size + space);

    if (progress > 0.5) {
      double right = start + size + distance;
      //progress=>0.5-1.0
      //left:0.0=>distance

      double left = index * distance + distance * (progress - 0.5) * 2;
      canvas.drawRRect(
          new RRect.fromLTRBR(
              left, 0.0, right, size, new Radius.circular(radius)),
          _paint);
    } else {
      double right = start + size + distance * progress * 2;

      canvas.drawRRect(
          new RRect.fromLTRBR(
              start, 0.0, right, size, new Radius.circular(radius)),
          _paint);
    }
  }
}


class DropPainter extends BasePainter {
  DropPainter(PageIndicator widget, double page, int index, Paint paint) : super(widget, page, index, paint);



  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    double dropHeight = widget.dropHeight;
    double rate = (0.5 - progress).abs() * 2;
    double scale = widget.scale;

    //lerp(begin, end, progress)

    canvas.drawCircle(
        new Offset(radius + ((page) * (size + space)),
            radius - dropHeight * (1 - rate)),
        radius * (scale + rate * (1.0 - scale)),
        _paint);
  }
}

class NonePainter extends BasePainter {
  NonePainter(PageIndicator widget, double page, int index, Paint paint) : super(widget, page, index, paint);



  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;
    if (progress > 0.5) {
      canvas.drawCircle(
          new Offset(radius + ((index + 1) * (size + space)), radius),
          radius,
          _paint);
    } else {
      canvas.drawCircle(new Offset(radius + (index * (size + space)), radius),
          radius, _paint);
    }
  }
}

class SlidePainter extends BasePainter {
  SlidePainter(PageIndicator widget, double page, int index, Paint paint) : super(widget, page, index, paint);



  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    canvas.drawCircle(
        new Offset(radius + (page * (size + space)), radius), radius, _paint);
  }
}

class ScalePainter extends BasePainter {

  final double scale;

  ScalePainter(PageIndicator widget, double page, int index, Paint paint,this.scale) : super(widget, page, index, paint);

  @override
  bool _shouldSkip(int i) {
    return i == index || i == index + 1;
  }
  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = widget.color;
    double space = widget.space;
    double size = widget.size;
    double radius = size / 2;
    for (int i = 0, c = widget.count; i < c; ++i) {
      if(_shouldSkip(i)){
        continue;
      }
      canvas.drawCircle(
          new Offset(i * (size + space) + radius, radius ), radius* widget.scale, _paint);
    }

    double page = this.page;
    if (page < index) {
      page = 0.0;
    }
    _paint.color = widget.activeColor;
    draw(canvas, space, size, radius);
  }

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;

    _paint.color = Color.lerp(widget.activeColor, widget.color, progress);
    //left
    canvas.drawCircle(new Offset(radius + (index * (size + space)), radius),
        lerp(radius, radius * 0.5, progress), _paint);
    //right
    _paint.color = Color.lerp(widget.color, widget.activeColor, progress);
    canvas.drawCircle(
        new Offset(radius + ((index + 1) * (size + space)), radius),
        lerp(radius * 0.5, radius, progress),
        _paint);
  }
}

class ColorPainter extends BasePainter {
  ColorPainter(PageIndicator widget, double page, int index, Paint paint) : super(widget, page, index, paint);


  @override
  bool _shouldSkip(int i) {
    return i == index || i == index + 1;
  }

  @override
  void draw(Canvas canvas, double space, double size, double radius) {
    double progress = page - index;

    _paint.color = Color.lerp(widget.activeColor, widget.color, progress);
    //left
    canvas.drawCircle(
        new Offset(radius + (index * (size + space)), radius), radius, _paint);
    //right
    _paint.color = Color.lerp(widget.color, widget.activeColor, progress);
    canvas.drawCircle(
        new Offset(radius + ((index + 1) * (size + space)), radius),
        radius,
        _paint);
  }
}

abstract class BasePainter extends CustomPainter {
  final PageIndicator widget;
  final double page;
  final int index;
  final Paint _paint;


  double lerp(double begin, double end, double progress) {
    return begin + (end - begin) * progress;
  }

  BasePainter(this.widget, this.page, this.index,this._paint);

  void draw(Canvas canvas, double space, double size, double radius);

  bool _shouldSkip(int index){
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = widget.color;
    double space = widget.space;
    double size = widget.size;
    double radius = size / 2;
    for (int i = 0, c = widget.count; i < c; ++i) {
      if(_shouldSkip(i)){
        continue;
      }
      canvas.drawCircle(
          new Offset(i * (size + space) + radius, radius), radius, _paint);
    }

    double page = this.page;
    if (page < index) {
      page = 0.0;
    }
    _paint.color = widget.activeColor;
    draw(canvas, space, size, radius);
  }

  @override
  bool shouldRepaint(BasePainter oldDelegate) {
    return oldDelegate.page != page;
  }
}

class _PageIndicatorState extends State<PageIndicator> {
  int index = 0;
  Paint _paint = new Paint();

  BasePainter _createPainer() {
    switch (widget.layout) {
      case PageIndicatorLayout.none:
        return new NonePainter(widget, widget.controller.page ?? 0.0, index,_paint);
      case PageIndicatorLayout.slide:
        return new SlidePainter(widget, widget.controller.page ?? 0.0, index,_paint);
      case PageIndicatorLayout.warm:
        return new WarmPainter(widget, widget.controller.page ?? 0.0, index,_paint);
      case PageIndicatorLayout.color:
        return new ColorPainter(widget, widget.controller.page ?? 0.0, index,_paint);
      case PageIndicatorLayout.scale:
        return new ScalePainter(
            widget, widget.controller.page ?? 0.0, index,_paint, widget.scale);
      case PageIndicatorLayout.drop:
        return new DropPainter(widget, widget.controller.page ?? 0.0, index,_paint);
      default:
        throw new Exception("Not a valid layout");
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget child = new SizedBox(
      width: widget.count * widget.size + (widget.count - 1) * widget.space,
      height: widget.size,
      child: new CustomPaint(
        painter: _createPainer(),
      ),
    );

    if(widget.layout == PageIndicatorLayout.scale || widget.layout == PageIndicatorLayout.color){
      child = new ClipRect(
        child: child,
      );
    }

    return new IgnorePointer(
      child: child,
    );
  }

  void _onController() {
    double page = widget.controller.page ?? 0.0;
    index = page.floor();

    setState(() {});
  }

  @override
  void initState() {
    widget.controller.addListener(_onController);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }
}

enum PageIndicatorLayout {
  none,
  slide,
  warm,
  color,
  scale,
  drop,
  // thinWarm,
}

class PageIndicator extends StatefulWidget {


  /// size of the dots
  final double size;

  /// space between dots.
  final double space;

  /// count of dots
  final int count;

  /// active color
  final Color activeColor;

  /// normal color
  final Color color;

  /// layout of the dots,default is [PageIndicatorLayout.slide]
  final PageIndicatorLayout layout;

  // Only valid when layout==PageIndicatorLayout.scale
  final double scale;

  // Only valid when layout==PageIndicatorLayout.drop
  final double dropHeight;

  final PageController controller;

  PageIndicator(
      {this.size,
      this.space,
      this.count,
      this.controller,
      this.color: Colors.white30,
      this.layout: PageIndicatorLayout.slide,
      this.activeColor: Colors.white,
      this.scale: 0.6,
      this.dropHeight: 20.0});

  @override
  State<StatefulWidget> createState() {
    return new _PageIndicatorState();
  }
}
