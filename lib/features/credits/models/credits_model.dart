// Credits model — a single credit transaction (debit or credit).

import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { debit, credit }

class CreditsModel {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final String reason;

  /// The scan, job, or payment reference this transaction is tied to —
  /// generic (not job-specific) so a scan charge or a Paystack purchase
  /// can be traced back to what it was actually for, same as a job can.
  final String? relatedEntityId;
  final DateTime createdAt;

  const CreditsModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.reason,
    this.relatedEntityId,
    required this.createdAt,
  });

  bool get isCredit => type == TransactionType.credit;

  factory CreditsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CreditsModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] == 'credit'
          ? TransactionType.credit
          : TransactionType.debit,
      amount: data['amount'] ?? 0,
      reason: data['reason'] ?? '',
      relatedEntityId: data['relatedEntityId'],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type == TransactionType.credit ? 'credit' : 'debit',
      'amount': amount,
      'reason': reason,
      if (relatedEntityId != null) 'relatedEntityId': relatedEntityId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}