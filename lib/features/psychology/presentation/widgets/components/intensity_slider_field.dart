import 'package:flutter/material.dart';

class IntensitySliderField extends StatelessWidget {
  const IntensitySliderField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Intensity: ${value.round()}'),
        Slider(min: 0, max: 100, value: value, onChanged: onChanged),
      ],
    );
  }
}
