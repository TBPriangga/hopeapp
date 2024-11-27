import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/home/carousel_model.dart';

class CarouselService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _carouselRef;

  CarouselService()
      : _carouselRef = FirebaseFirestore.instance.collection('carousels');

  Stream<List<CarouselModel>> getActiveCarousels() {
    try {
      print('Starting to fetch active carousels stream');
      return _carouselRef
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        print('Received snapshot with ${snapshot.docs.length} documents');
        return snapshot.docs.map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            print('Processing document ${doc.id}');
            return CarouselModel.fromMap(doc.id, data);
          } catch (e) {
            print('Error processing document ${doc.id}: $e');
            rethrow;
          }
        }).toList();
      });
    } catch (e) {
      print('Error in getActiveCarousels: $e');
      rethrow;
    }
  }

  Future<List<CarouselModel>> getActiveCarouselsOnce() async {
    try {
      print('Fetching active carousels');
      final snapshot = await _carouselRef
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      print('Received ${snapshot.docs.length} documents');

      return Future.wait(snapshot.docs.map((doc) async {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print('Processing document ${doc.id}');
          return CarouselModel.fromMap(doc.id, data);
        } catch (e) {
          print('Error processing document ${doc.id}: $e');
          throw Exception('Failed to process carousel document: $e');
        }
      }));
    } catch (e) {
      print('Error in getActiveCarouselsOnce: $e');
      throw Exception('Failed to fetch carousels: $e');
    }
  }

  // Helper method untuk debug
  Future<void> validateCollection() async {
    try {
      final snapshot = await _carouselRef.get();
      print('Total documents in collection: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        print('Document ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }
    } catch (e) {
      print('Error validating collection: $e');
    }
  }
}
