import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;
  final bool withAnimation;

  CustomPageRoute({
    required this.child,
    this.withAnimation = true,
  }) : super(
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (!withAnimation) return child;

    const begin = Offset(0.0, 0.05);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: offsetAnimation,
        child: child,
      ),
    );
  }
}
