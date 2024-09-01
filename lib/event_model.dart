import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String eventName;
  final String communityId;
  final DateTime eventDate;
  final DateTime orderDeadline; // 注文締切日
  final String location;
  final bool isBulk; // 一括配送かどうか
  final int participantCount;
  final int shippingCost;

  EventModel({
    required this.eventId,
    required this.eventName,
    required this.communityId,
    required this.eventDate,
    required this.orderDeadline, // 注文締切日
    required this.location,
    required this.isBulk,
    required this.participantCount,
    required this.shippingCost,
  });

  // Firestoreからデータを取得するためのファクトリメソッド
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EventModel(
      eventId: data['eventId'] ?? '',
      eventName: data['eventName'] ?? '',
      communityId: data['communityId'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      orderDeadline: (data['orderDeadline'] as Timestamp).toDate(), // 注文締切日
      location: data['location'] ?? '',
      isBulk: data['isBulk'] ?? false,
      participantCount: data['participantCount'] ?? 0,
      shippingCost: data['shippingCost'] ?? 950, // デフォルト送料を設定
    );
  }

  // Firestoreにデータを保存するためのメソッド
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'communityId': communityId,
      'eventDate': eventDate,
      'orderDeadline': orderDeadline, // 注文締切日
      'location': location,
      'isBulk': isBulk,
      'participantCount': participantCount,
      'shippingCost': shippingCost,
    };
  }
}
