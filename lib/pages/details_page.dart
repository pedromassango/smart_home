import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:smart_home/radial_gesture_detector.dart';


class DetailsPage extends StatefulWidget {
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

final Color bgColor = Color(0xFF100d30);
final Color whiteColor = Colors.white;
final Color accentColor = Color(0xFFff5102);

class _DetailsPageState extends State<DetailsPage> with
    SingleTickerProviderStateMixin{

  int value = 0;
  Duration _slideAnimationDuration = Duration(milliseconds: 500);
  Duration _opacityAnimationDuration = Duration.zero;

  Animation _animation;
  AnimationController _controller;

  int selectedOptionIndex = 0;
  final iconOptions =[
    Icons.ac_unit,
    Icons.trip_origin,
    Icons.short_text,
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this,
        duration: _slideAnimationDuration
    );

    _animation = Tween<double>(
        begin: 0, end: 140
    ).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Curves.fastOutSlowIn,
      ),
    );

    Future.delayed(Duration(milliseconds: 1), (){
      _controller.forward();
    });

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(),
        title: Text("Air Conditioning", style: TextStyle(
            fontWeight: FontWeight.normal
        ),),
        actions: <Widget>[
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.power_settings_new, color: accentColor, size: 32,),
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: <Widget>[

              Positioned(
                  top: size.height / 3,
                  left: 16,
                  child: AnimatedOpacity(
                    opacity: _controller.value,
                    duration: _opacityAnimationDuration,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Temperature, ºF", style: TextStyle(
                            fontSize: 17,
                            color: Colors.white
                        ),
                        ),
                        SizedBox(height: 8,),
                        Text("$value", style: TextStyle(
                            fontSize: 80,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                        ),
                      ],
                    ),
                  )
              ),

              Positioned(
                left: 16,
                bottom: 60,
                child: AnimatedOpacity(
                  opacity: _controller.value,
                  duration: _opacityAnimationDuration,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[

                          Icon(Icons.schedule, color: accentColor,),
                          SizedBox(width: 8,),
                          Text("Set Smart Schedule",
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 17
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 32,),

                      Row(
                        children: iconOptions.map((icon){
                          final index = iconOptions.indexOf(icon);

                          return GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedOptionIndex = index;
                              });
                            },
                            child: _CircleIconSelector(
                              icon: icon,
                              isSelected: selectedOptionIndex ==
                                index,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: MediaQuery.of(context).size.width- _animation.value,
                child: AnimatedOpacity(
                  opacity: _controller.value,
                  duration: _opacityAnimationDuration,
                  child: WellPicker(
                    onValue: (value){
                      this.value = value;
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CircleIconSelector extends StatefulWidget {

  final IconData icon;
  final bool isSelected;
  const _CircleIconSelector({
    Key key,
    this.icon,
    this.isSelected
  }) : super(key: key);


  @override
  __CircleIconSelectorState createState() => __CircleIconSelectorState();
}

class __CircleIconSelectorState extends State<_CircleIconSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isSelected ? accentColor : bgColor,
        border: Border.all(
          color: Colors.grey.withOpacity(0.5)
        )
      ),
      child: Center(
        child: Icon(
            widget.icon,
          size: 32,
          color: widget.isSelected ? whiteColor : Colors.grey.withOpacity(0.4),
        ),
      ),
    );
  }
}


class WellPicker extends StatefulWidget {

  final ValueChanged<int> onValue;

  const WellPicker({Key key, this.onValue}) : super(key: key);

  @override
  _WelPickerState createState() => _WelPickerState();
}

class _WelPickerState extends State<WellPicker> {

  final int minValue = 0;
  final int maxValue = 100;
  final double speed = 0.1;

  double size;

  double position;
  double angle = 0.1;
  double prevAngle = 0;
  PolarCoord startCoord;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.height/1.2;

    return RadialDragGestureDetector(
      onRadialDragEnd: _onDragEnd,
      onRadialDragStart: _dragStart,
      onRadialDragUpdate: _dragUpdate,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          height: size,
          width: size,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                  color: accentColor,
                  width: 5
              ),

          ),
          child: CustomPaint(
            painter: IndicatorPainter(),
          ),
        ),
      ),
    );
  }

  _onDragEnd(){
    startCoord = null;
    prevAngle = 0;
  }

  _dragStart(PolarCoord coord) {
    startCoord = coord;
    prevAngle = coord.angle;
  }

  _dragUpdate(PolarCoord coord) {
    if (startCoord == null) {
      return;
    }

    double angleDiff = coord.angle.remainder(startCoord.angle);

    if (angleDiff >= prevAngle && angle <= maxValue) {
      angle += speed;
    } else if (angleDiff <= prevAngle && angle >= minValue) {
      angle -= speed;
    }

    prevAngle = angleDiff;

    _update(angle);
  }

  _update(double value) => setState(()=> widget.onValue(value.round()));
}

class IndicatorPainter extends CustomPainter{

  Paint line;
  final int lineHeight = 30;
  final int maxIndicators = 150;

  IndicatorPainter():
        line = Paint()
          ..color = Colors.deepOrange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width/2, size.height/2);

    canvas.save();

    final radius = size.width / 2;

    List.generate(maxIndicators, (i) {
      canvas.drawLine(
          Offset(0, radius),
          Offset(0, radius - lineHeight),
          line
      );

      canvas.rotate( 2 * pi / maxIndicators);
    });

    canvas.restore();

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}