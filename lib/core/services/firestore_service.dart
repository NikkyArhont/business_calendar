import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/calendar_event.dart';
import '../models/assistant_access.dart';

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

  Future<void> updateEvent(String eventId, CalendarEvent event) async {
    if (_userId == null) return;
    await _eventsCollection.doc(eventId).update(event.toMap());
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

  Future<Map<String, dynamic>?> getContact(String contactId) async {
    if (_userId == null) return null;
    final doc = await _contactsCollection.doc(contactId).get();
    if (doc.exists) {
      return {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      };
    }
    return null;
  }

  Future<void> updateContact(String contactId, Map<String, dynamic> contactData) async {
    if (_userId == null) return;
    await _contactsCollection.doc(contactId).update({
      ...contactData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteContact(String contactId) async {
    if (_userId == null) return;
    await _contactsCollection.doc(contactId).delete();
  }

  // --- ASSISTANTS ---

  CollectionReference get _assistantsCollection => 
    _firestore.collection('users').doc(_userId).collection('assistants');

  Future<void> addAssistant(AssistantAccess assistant) async {
    if (_userId == null) return;
    await _assistantsCollection.add(assistant.toMap());
  }

  Stream<List<AssistantAccess>> getAssistants() {
    if (_userId == null) return Stream.value([]);
    return _assistantsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AssistantAccess.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> deleteAssistant(String assistantId) async {
    if (_userId == null) return;
    await _assistantsCollection.doc(assistantId).delete();
  }
}
