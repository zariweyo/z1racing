import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:z1racing/ads/controller/admob_controller.dart';
import 'package:z1racing/domain/repositories/cache_repository.dart';
import 'package:z1racing/domain/repositories/firebase_auth_repository.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/domain/repositories/preferences_repository.dart';
import 'package:z1racing/enviroment/enviroment_repository.dart';
import 'package:z1racing/z1racing_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  FirebaseFirestoreRepository.initInMockMode;
  FirebaseAuthRepository.initInMockMode;
  EnviromentRepository.initInMockMode;
  AdmobController.initInMockMode;
  PreferencesRepository.instance.init();
  CacheRepository.instance.init();
  runApp(
    const Z1RacingWidget(),
  );
}
