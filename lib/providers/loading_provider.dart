import 'package:flutter/foundation.dart';

class LoadingProvider with ChangeNotifier {
  bool _isLoading = false;
  String _loadingText = 'Loading...';

  bool get isLoading => _isLoading;
  String get loadingText => _loadingText;

  void showLoading([String text = 'Loading...']) {
    _isLoading = true;
    _loadingText = text;
    notifyListeners();
  }

  void hideLoading() {
    _isLoading = false;
    notifyListeners();
  }

  // For async operations with automatic loading
  Future<T> runWithLoading<T>(Future<T> Function() computation,
      [String loadingText = 'Loading...']) async {
    showLoading(loadingText);
    try {
      final result = await computation();
      hideLoading();
      return result;
    } catch (e) {
      hideLoading();
      rethrow;
    }
  }
}