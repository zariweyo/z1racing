import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:z1racing/extensions/duration_extension.dart';

class DurationWidget extends StatelessWidget {
  final Duration duration;
  final Color? color;
  final FontWeight? fontWeight;
  final double size;

  const DurationWidget({
    required this.duration,
    this.color,
    this.fontWeight,
    this.size = 30,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.martianMonoTextTheme();
    final colorBase = color ?? Colors.white54;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          duration.minutesString(),
          style: textTheme.bodyLarge?.copyWith(
            color: colorBase,
            fontWeight: fontWeight,
            fontSize: size,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
        const SizedBox(
          width: 1,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              duration.secondsString(),
              style: textTheme.bodyMedium?.copyWith(
                color: colorBase,
                fontWeight: fontWeight,
                fontSize: size - 11,
                height: 0,
              ),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
            ),
            Text(
              '.${duration.millisString()}',
              style: textTheme.bodySmall?.copyWith(
                color: colorBase,
                fontWeight: fontWeight,
                fontSize: size - 16,
                height: 0,
              ),
              softWrap: true,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
