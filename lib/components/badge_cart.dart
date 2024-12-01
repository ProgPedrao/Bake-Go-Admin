import 'package:flutter/material.dart';

class BadgeCart extends StatelessWidget {
  const BadgeCart(
      {super.key, required this.child, required this.value, this.color});

  final Widget child;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          top: 4,
          right: 8,
          child: Container(
            constraints: const BoxConstraints(minHeight: 16, minWidth: 16),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color ?? Theme.of(context).primaryColor,
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
