import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:z1racing/ads/controller/admob_controller.dart';
import 'package:z1racing/repositories/cache_repository.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/repositories/preferences_repository.dart';
import 'package:z1racing/z1racing_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  FirebaseFirestoreRepository.initInMockMode;
  FirebaseAuthRepository.initInMockMode;
  AdmobController.initInMockMode;
  PreferencesRepository.instance.init();
  CacheRepository().init();
  runApp(
    const Z1RacingWidget(),
  );
}
