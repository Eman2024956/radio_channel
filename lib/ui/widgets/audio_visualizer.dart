import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final int barCount;
  final double height;
  final double width;
  final Color? color;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    this.barCount = 4,
    this.height = 20,
    this.width = 3,
    this.color,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<double> _barHeights;

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(widget.barCount, (_) => 0.3);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..addListener(() {
        if (widget.isPlaying) {
          setState(() {
            for (int i = 0; i < widget.barCount; i++) {
              _barHeights[i] = 0.2 + _random.nextDouble() * 0.8;
            }
          });
        }
      });

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        setState(() {
          for (int i = 0; i < widget.barCount; i++) {
            _barHeights[i] = 0.2;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? AppTheme.primaryNeon;

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: widget.width,
            height: widget.height * _barHeights[index],
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(widget.width),
              boxShadow: widget.isPlaying
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 0.5,
                      )
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
