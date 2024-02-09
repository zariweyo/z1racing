import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/button_action.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';

class ByButton extends StatefulWidget {
  const ByButton({super.key});

  @override
  State<ByButton> createState() => _ByButtonState();
}

class _ByButtonState extends State<ByButton> {
  @override
  void initState() {
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
    setState(() {});
  }

  Future<void> showExitConfirmationDialog(BuildContext context) async {
    final textStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white);
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // El usuario debe tocar un botón para cerrar el diálogo
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.black,
          titleTextStyle: textStyle,
          contentTextStyle: textStyle,
          content: Text(
            AppLocalizations.of(context)!.confirmClose,
            style: textStyle,
          ),
          actions: <Widget>[
            ButtonActions(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: textStyle,
              ),
              onTap: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
              },
            ),
            ButtonActions(
              child: Text(
                AppLocalizations.of(context)!.closeApp,
                style: textStyle,
              ),
              onTap: () {
                SystemNavigator.pop(); // Cierra la aplicación
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = FirebaseFirestoreRepository.instance.avatarColor;
    return ButtonActions(
      onTap: () {
        showExitConfirmationDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Icon(Icons.logout_outlined, color: color.shade50),
      ),
    );
  }
}
