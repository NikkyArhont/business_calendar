import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/calendar_event.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // --- EVENTS ---

  CollectionReference get _eventsCollection => 
    _firestore.collection('users').doc(_userId).collection('events');

  Future<void> addEvent(CalendarEvent event) async {
    if (_userId == null) return;
    await _eventsCollection.add(event.toMap());
  }

  Stream<List<CalendarEvent>> getEvents() {
    if (_userId == null) return Stream.value([]);
    return _eventsCollection
      .orderBy('startTime', descending: false)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return CalendarEvent.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
  }

  Future<void> deleteEvent(String eventId) async {
    if (_userId == null) return;
    await _eventsCollection.doc(eventId).delete();
  }

  // --- CONTACTS ---

  CollectionReference get _contactsCollection => 
    _firestore.collection('users').doc(_userId).collection('contacts');

  Future<void> addContact(Map<String, dynamic> contactData) async {
    if (_userId == null) return;
    await _contactsCollection.add({
      ...contactData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getContacts() {
    if (_userId == null) return Stream.value([]);
    return _contactsCollection
      .orderBy('name', descending: false)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          };
        }).toList();
      });
  }

  Future<void> deleteContact(String contactId) async {
    if (_userId == null) return;
    await _contactsCollection.doc(contactId).delete();
  }
}
