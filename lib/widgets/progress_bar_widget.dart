import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final double progress;
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final EdgeInsetsGeometry? margin;

  const ProgressBarWidget({
    Key? key,
    required this.progress,
    this.height = 10.0,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = const Color(0xFF4CAF50),
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure progress is between 0.0 and 1.0
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedProgress,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              colors: [
                progressColor.withOpacity(0.7),
                progressColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
    );
  }
}

class CircularProgressBarWidget extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  const CircularProgressBarWidget({
    Key? key,
    required this.progress,
    this.size = 50.0,
    this.strokeWidth = 5.0,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = const Color(0xFF4CAF50),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure progress is between 0.0 and 1.0
    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          ),
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              value: clampedProgress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          Center(
            child: Text(
              '${(clampedProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: size / 4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
