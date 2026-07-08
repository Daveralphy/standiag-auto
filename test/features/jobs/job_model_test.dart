import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/features/jobs/models/job_model.dart';

void main() {
  test('JobStatusExtension parses Firestore values', () {
    expect(JobStatusExtension.fromString('accepted'), JobStatus.accepted);
    expect(JobStatusExtension.fromString('en_route'), JobStatus.enRoute);
    expect(JobStatusExtension.fromString('unknown'), JobStatus.pending);
  });

  test('JobStatusExtension returns Firestore strings', () {
    expect(JobStatus.completed.value, 'completed');
    expect(JobStatus.inProgress.value, 'in_progress');
  });
}
