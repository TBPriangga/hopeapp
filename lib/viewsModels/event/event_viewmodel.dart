import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/event/event_service.dart';
import '../../models/event/event_model.dart';

class EventViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;

  EventModel? _selectedEvent;
  bool _isLoadingDetail = false;
  String? _detailError;
  StreamSubscription? _eventsSubscription;

  // Getters
  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasEvents => _events.isNotEmpty;

  EventModel? get selectedEvent => _selectedEvent;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  // Load Events List
  Future<void> loadEvents() async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _error = null;

      // Cancel existing subscription if any
      await _eventsSubscription?.cancel();

      _eventsSubscription = _eventService.getAllEvents().listen(
        (events) {
          _events = events;
          _setLoading(false);
        },
        onError: (error) {
          _error = error.toString();
          _setLoading(false);
        },
      );
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // Helper method untuk update loading state
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  // Load Event Detail
  Future<void> loadEventDetail(String eventId) async {
    if (_isLoadingDetail) return;

    try {
      _setLoadingDetail(true);
      _detailError = null;

      _selectedEvent = await _eventService.getEventById(eventId);

      _setLoadingDetail(false);
    } catch (e) {
      _detailError = e.toString();
      _setLoadingDetail(false);
    }
  }

  void _setLoadingDetail(bool value) {
    if (_isLoadingDetail != value) {
      _isLoadingDetail = value;
      notifyListeners();
    }
  }

  // Get Upcoming Events
  Stream<List<EventModel>> getUpcomingEvents({int limit = 3}) {
    return _eventService.getUpcomingEvents(limit: limit);
  }

  // Get All Events
  Stream<List<EventModel>> getAllEvents() {
    return _eventService.getAllEvents();
  }

  // Launch Material URL
  Future<void> launchMaterialUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      _setError('Tidak dapat membuka link: $e');
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  // Refresh Events
  Future<void> refreshEvents() async {
    _error = null;
    await loadEvents();
  }

  // Clear selected event
  void clearSelectedEvent() {
    if (_selectedEvent != null || _detailError != null || _isLoadingDetail) {
      _selectedEvent = null;
      _detailError = null;
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}
