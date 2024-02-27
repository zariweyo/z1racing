import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/button_action.dart';
import 'package:z1racing/base/components/by_button.dart';
import 'package:z1racing/domain/entities/z1user.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';
import 'package:z1racing/menus/widgets/settings/menu_settings.dart';

class MenuHeader extends StatefulWidget {
  const MenuHeader({super.key});

  @override
  State<MenuHeader> createState() => _MenuHeaderState();
}

class _MenuHeaderState extends State<MenuHeader> {
  Z1User? z1User;

  @override
  void initState() {
    z1User = FirebaseFirestoreRepository.instance.currentUser;
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
      z1User = FirebaseFirestoreRepository.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = FirebaseFirestoreRepository.instance.avatarColor;
    return Row(
      children: [
        Expanded(
          child: ButtonActions(
            onTap: () {
              MenuSettings.open(context: context);
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              alignment: Alignment.topRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleName(context: context)),
                  Icon(
                    Icons.settings,
                    color: color.shade50,
                  ),
                ],
              ),
            ),
          ),
        ),
        const ByButton(),
      ],
    );
  }

  Widget titleName({required BuildContext context}) {
    final textTheme = Theme.of(context).textTheme;
    final name = z1User?.name ?? '';
    return Text(
      AppLocalizations.of(context)!
          .homeHello
          .replaceAll('%%USERNAME%%', name.toUpperCase()),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: textTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }
}
