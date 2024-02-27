import 'package:flutter/material.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/extensions/z1useravatar_extension.dart';

class SettingsAvatar extends StatefulWidget {
  const SettingsAvatar({super.key});

  @override
  State<SettingsAvatar> createState() => _SettingsAvatarState();
}

class _SettingsAvatarState extends State<SettingsAvatar> {
  late Z1UserAvatar z1UserAvatar;

  @override
  void initState() {
    super.initState();
    z1UserAvatar =
        FirebaseFirestoreRepository.instance.currentUser?.z1UserAvatar ??
            Z1UserAvatar.girl_1;
  }

  Widget _item(Z1UserAvatar avatar) {
    final backgroundColor = z1UserAvatar == avatar
        ? avatar.avatarBackgroundColor
        : avatar.avatarBackgroundColor.withAlpha(60);
    return InkWell(
      onTap: () {
        setState(() {
          z1UserAvatar = avatar;
          FirebaseFirestoreRepository.instance.updateAvatar(avatar);
        });
      },
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(right: 10),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
        ),
        child: Image.asset(
          avatar.avatarBasePath,
          opacity: AlwaysStoppedAnimation(z1UserAvatar == avatar ? 1 : 0.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: Z1UserAvatar.values.map(_item).toList(),
      ),
    );
  }
}
