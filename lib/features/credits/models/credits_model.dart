// Credits model — a single credit transaction (debit or credit).

import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { debit, credit }

class CreditsModel {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final String reason;
  final String? relatedJobId;
  final DateTime createdAt;

  const CreditsModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.reason,
    this.relatedJobId,
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
      relatedJobId: data['relatedJobId'],
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
      if (relatedJobId != null) 'relatedJobId': relatedJobId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}