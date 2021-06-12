import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test/src/prime_wait_run.dart';
import 'package:riverpod_test/src/riverpod-test-stage.dart';
import 'package:riverpod_test/src/riverpod.dart';

Future<void> riverpodSetupTestExpect({
  SetupFunction? defaultSetup,
  bool log = false,
  List<Override> overrides = const [],
  required RiverpodTestStage setup,
  required RiverpodTestStage test,
  required RiverpodTestStage expect,
}) async {
  Completer completer = Completer<void>();

  /// Setup Riverpod container
  final riverpod = Riverpod.create(overrides: overrides, log: log);

  /// do the 'setup' for the test
  await primeWaitRun(
    riverpod: riverpod,
    primeDependencies: setup.dependencies,
    pauseMillis: setup.delay,
    action: (riverpod, context) async {
      final setupResultContext = setup.execute(riverpod, context);

      /// do the 'test' part of the test
      await primeWaitRun(
        riverpod: riverpod,
        context: setupResultContext,
        primeDependencies: test.dependencies,
        pauseMillis: test.delay,
        action: (riverpod, context) async {
          final testResultContext = test.execute(riverpod, context);

          /// do the 'expect' part of the test
          await primeWaitRun(
            riverpod: riverpod,
            context: testResultContext,
            primeDependencies: expect.dependencies,
            pauseMillis: expect.delay,
            action: (riverpod, context) async {
              expect.execute(riverpod, context);
              completer.complete();
            },
          );
        },
      );
    },
  );
  return completer.future;
}
