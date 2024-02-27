import 'package:flutter/material.dart';
import 'package:z1racing/ads/components/admob_reward_button.dart';
import 'package:z1racing/base/components/update_button.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/extensions/z1useravatar_extension.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool initiated = false;
  late Z1User z1User;

  @override
  void initState() {
    z1User = FirebaseFirestoreRepository.instance.currentUser!;
    FirebaseFirestoreRepository.instance.currentUserNotifier
        .addListener(_currentUserModified);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    FirebaseFirestoreRepository.instance.currentUserNotifier
        .removeListener(_currentUserModified);
  }

  void _currentUserModified() {
    setState(() {
      z1User = FirebaseFirestoreRepository.instance.currentUser!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/images/logo_alpha.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 5),
                  const AdmobRewardButton(),
                  const UpdateButton(),
                ],
              ),
              Column(
                children: [
                  Container(
                    height: 150,
                    child: Image.asset(z1User.z1UserAvatar.avatarBasePath),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
