import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:z1racing/ads/controller/admob_controller.dart';
import 'package:z1racing/z1racing_widget.dart';

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      AdmobController.initInProdMode;
      runApp(
        const Z1RacingWidget(),
      );
    },
    (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack),
  );
}
