// Quote model — a mechanic's price + note response to an open
// ServiceRequestModel. Stored at serviceRequests/{requestId}/quotes/{mechanicId}
// — keyed by mechanic id so a mechanic can only have one active quote per
// request.

import 'package:cloud_firestore/cloud_firestore.dart';

enum QuoteStatus { pending, accepted, declined, expired }

extension QuoteStatusExtension on QuoteStatus {
  String get value {
    switch (this) {
      case QuoteStatus.pending:
        return 'pending';
      case QuoteStatus.accepted:
        return 'accepted';
      case QuoteStatus.declined:
        return 'declined';
      case QuoteStatus.expired:
        return 'expired';
    }
  }

  static QuoteStatus fromString(String value) {
    switch (value) {
      case 'accepted':
        return QuoteStatus.accepted;
      case 'declined':
        return QuoteStatus.declined;
      case 'expired':
        return QuoteStatus.expired;
      default:
        return QuoteStatus.pending;
    }
  }
}

class QuoteModel {
  final String mechanicId;
  final double price;
  final String? note;
  final QuoteStatus status;
  final DateTime createdAt;

  const QuoteModel({
    required this.mechanicId,
    required this.price,
    this.note,
    required this.status,
    required this.createdAt,
  });

  factory QuoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuoteModel(
      mechanicId: doc.id,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      note: data['note'] as String?,
      status: QuoteStatusExtension.fromString(data['status'] ?? 'pending'),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'price': price,
      if (note != null && note!.isNotEmpty) 'note': note,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
