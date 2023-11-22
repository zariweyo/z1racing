import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LoadingWidget extends StatefulWidget {
  LoadingWidget({super.key});
  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  double width = 90;
  int points = 3;

  @override
  initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          width = 100;
        });
      }
    });
    super.initState();
  }

  _logo(BuildContext context) {
    return AnimatedContainer(
        height: 100,
        width: width,
        onEnd: () {
          if (points == 3) points = -1;
          if (width == 100) {
            setState(() {
              width = 90;
              points++;
            });
          } else {
            setState(() {
              width = 100;
              points++;
            });
          }
        },
        duration: Duration(milliseconds: 600),
        child: Image.asset(
          "assets/images/logo_alpha.png",
          height: 100,
          width: width,
          fit: BoxFit.contain,
        ));
  }

  _text(BuildContext context) {
    return Text(
      'Loading' +
          List.generate(points, (index) => ".").join() +
          List.generate(3 - points, (index) => " ").join(),
      textAlign: TextAlign.start,
      style: Theme.of(context)
          .textTheme
          .displayMedium
          ?.copyWith(color: Colors.white, fontSize: 35),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_logo(context), _text(context)]),
    );
  }
}
