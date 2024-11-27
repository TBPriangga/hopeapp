import 'package:flutter/material.dart';
import '../../core/services/home/carousel_service.dart';
import '../../models/home/carousel_model.dart';

class CarouselViewModel extends ChangeNotifier {
  final CarouselService _carouselService = CarouselService();

  List<CarouselModel> _carousels = [];
  bool _isLoading = true;
  String? _error;

  // Getters
  List<CarouselModel> get carousels => _carousels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Current page for carousel
  int _currentPage = 0;
  int get currentPage => _currentPage;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  // Load carousels
  Future<void> loadCarousels() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Debug: Validate collection first
      await _carouselService.validateCollection();

      final carousels = await _carouselService.getActiveCarouselsOnce();
      _carousels = carousels;

      print('Successfully loaded ${carousels.length} carousels');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error in loadCarousels: $e');
      _error = 'Failed to load carousel data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handle carousel item tap
  Future<String?> handleCarouselTap(
      BuildContext context, CarouselModel carousel) async {
    if (carousel.linkType == null || carousel.linkUrl == null) {
      return null;
    }

    if (carousel.linkType == 'internal' && carousel.internalRoute != null) {
      return carousel.internalRoute;
    } else if (carousel.linkType == 'external' && carousel.linkUrl != null) {
      // Handle external URL (you might want to use url_launcher package)
      return carousel.linkUrl;
    }

    return null;
  }
}
