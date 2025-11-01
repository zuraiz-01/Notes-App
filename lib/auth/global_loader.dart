import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_provider.dart';

class GlobalLoader extends StatelessWidget {
  final Widget child;
  const GlobalLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<LoadingProvider>().isLoading;

    return Stack(
      children: [
        child, // main app content
        if (isLoading)
          Container(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE76F3C), // accentOrange
                strokeWidth: 4,
              ),
            ),
          ),
      ],
    );
  }
}
