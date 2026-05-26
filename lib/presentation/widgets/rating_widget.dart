import 'package:flutter/material.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';

class RatingWidget extends StatefulWidget {
  final double? initialRating;
  final bool readOnly;
  final ValueChanged<int>? onRatingChanged;
  final double size;

  const RatingWidget({
    Key? key,
    this.initialRating,
    this.readOnly = false,
    this.onRatingChanged,
    this.size = 24.0,
  }) : super(key: key);

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = (widget.initialRating ?? 0).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final rating = index + 1;
        final isFilled = rating <= _currentRating;

        return GestureDetector(
          onTap: widget.readOnly
              ? null
              : () {
                  setState(() {
                    _currentRating = rating;
                  });
                  widget.onRatingChanged?.call(rating);
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              color: AppTheme.primaryColor,
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}
