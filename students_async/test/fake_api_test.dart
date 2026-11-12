import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:students_async/api/fake_api.dart';

void main() {
  setUp(FakeApi.resetSaves);

  test('fetchStudents waits two seconds and fails every third call', () {
    fakeAsync((async) {
      final api = FakeApi();
      final results = <Object>[];
      for (var i = 0; i < 3; i++) {
        api.fetchStudents().then(
          (l) => results.add(l.length),
          onError: (Object e) => results.add(e),
        );
      }
      async.elapse(const Duration(milliseconds: 1999));
      expect(results, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      expect(results.take(2), [6, 6]);
      expect(results[2], isA<NoConnectionException>());
      expect(api.calls, 3);
    });
  });

  test('empty server answers an empty list', () async {
    final api = FakeApi(empty: true);
    await expectLater(api.fetchStudents(), completion(isEmpty));
  });

  test('save fails every second call with a StateError', () async {
    final api = FakeApi();
    await api.save(6);
    await expectLater(
      api.save(6),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          'server rejected 6',
        ),
      ),
    );
    await api.save(6);
  });
}
