import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class EmptyChart extends StatelessWidget {
  final String message;

  const EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: FadeIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pulse(
                infinite: true,
                duration: const Duration(seconds: 2),
                child: Icon(Icons.bar_chart_outlined,
                    size: 48, color: Colors.grey[300]),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}