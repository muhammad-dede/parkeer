import 'package:flutter/material.dart';

class FormGroup extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const FormGroup({super.key, required this.children, this.spacing = 4.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final widget = entry.value;

        if (index < children.length - 1) {
          return Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: widget,
          );
        }

        return widget;
      }).toList(),
    );
  }
}
