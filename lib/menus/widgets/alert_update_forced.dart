import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:z1racing/models/z1version.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';

class AlertUpdateForced extends StatelessWidget {
  AlertUpdateForced();

  _linkUpdate(BuildContext context) {
    Z1Version z1Version = FirebaseFirestoreRepository().z1version;
    return ElevatedButton(
        onPressed: () {
          String url = "";
          if (Platform.isAndroid) {
            url = z1Version.android;
          } else if (Platform.isIOS) {
            url = z1Version.ios;
          }

          if (url.isNotEmpty) {
            launchUrl(Uri.parse(url));
          }
        },
        child: Text("UPDATE",
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white)));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.black,
        child: Center(
            child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo_alpha.png",
                height: 100,
                fit: BoxFit.contain,
              ),
              Text(
                "You need to update to last version to continue playing",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              _linkUpdate(context)
            ],
          ),
        )));
  }
}
