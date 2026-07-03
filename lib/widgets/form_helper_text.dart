import 'package:flutter/material.dart';

class FormHelperText extends StatelessWidget {
  const FormHelperText({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.only(left: 4),
  });

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
    );
  }
}
