import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loading_provider.dart';

class GlobalLoadingOverlay extends StatelessWidget {
  final Widget child;

  const GlobalLoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final loadingProvider = Provider.of<LoadingProvider>(context);

    return Stack(
      children: [
        // Main app content
        child,

        // Loading overlay
        if (loadingProvider.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: _buildLoadingContent(loadingProvider.loadingText),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingContent(String text) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}