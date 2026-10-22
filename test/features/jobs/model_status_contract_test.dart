import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/features/jobs/models/job_model.dart';
import 'package:standiag_auto/features/jobs/models/quote_model.dart';
import 'package:standiag_auto/features/jobs/models/service_request_model.dart';

void main() {
  group('JobStatus persistence contract', () {
    test('round-trips every persisted status value', () {
      for (final status in JobStatus.values) {
        expect(JobStatusExtension.fromString(status.value), status);
      }
    });

    test('unknown status values safely default to pending', () {
      expect(JobStatusExtension.fromString('unexpected'), JobStatus.pending);
    });
  });

  group('ServiceRequestStatus persistence contract', () {
    test('round-trips every persisted status value', () {
      for (final status in ServiceRequestStatus.values) {
        expect(ServiceRequestStatusExtension.fromString(status.value), status);
      }
    });

    test('unknown status values safely default to open', () {
      expect(
        ServiceRequestStatusExtension.fromString('unexpected'),
        ServiceRequestStatus.open,
      );
    });
  });

  group('QuoteStatus persistence contract', () {
    test('round-trips every persisted status value', () {
      for (final status in QuoteStatus.values) {
        expect(QuoteStatusExtension.fromString(status.value), status);
      }
    });

    test('unknown status values safely default to pending', () {
      expect(QuoteStatusExtension.fromString('unexpected'), QuoteStatus.pending);
    });
  });
}
