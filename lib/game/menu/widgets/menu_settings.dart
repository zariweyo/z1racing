import 'package:flutter/material.dart';
import 'package:z1racing/game/repositories/firebase_auth_repository.dart';
import 'package:z1racing/game/repositories/firebase_firestore_repository.dart';

class MenuSettings extends StatefulWidget {
  static Future open({required BuildContext context}) {
    return showDialog(context: context, builder: ((ctx) => MenuSettings()));
  }

  @override
  State<MenuSettings> createState() => _MenuSettingsState();
}

class _MenuSettingsState extends State<MenuSettings> {
  late TextEditingController controller;
  late FocusNode focusNode;
  bool loading = false;
  @override
  initState() {
    super.initState();
    String displayName =
        FirebaseAuthRepository().currentUser?.displayName ?? "";
    controller = TextEditingController(text: displayName);
    focusNode = FocusNode();
  }

  @override
  dispose() {
    super.dispose();
  }

  _nameUpdated(String newName) async {
    focusNode.unfocus();

    if (FirebaseFirestoreRepository().currentUser?.displayName != newName) {
      setState(() {
        loading = true;
      });
      await FirebaseFirestoreRepository().updateName(newName);
      setState(() {
        loading = false;
      });
    }
  }

  _backButton(BuildContext context) {
    return Container(
        width: 100,
        child: ElevatedButton.icon(
            onPressed: () {
              if (!loading) {
                Navigator.of(context).pop();
              }
            },
            icon: Icon(
              Icons.arrow_back,
              color: loading ? Colors.white24 : Colors.white70,
            ),
            label: Text("")));
  }

  Widget _loadingWidget() {
    if (loading) {
      return Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ));
    }

    return _version();
  }

  _textfield() {
    return Expanded(
        child: Row(children: [
      Text("Nickname: "),
      Expanded(
          child: TextField(
        focusNode: focusNode,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlignVertical: TextAlignVertical.bottom,
        controller: controller,
        maxLength: 15,
        onSubmitted: _nameUpdated,
        onTapOutside: (_) {
          _nameUpdated(controller.text);
        },
      ))
    ]));
  }

  _version() {
    String version = FirebaseAuthRepository().packageInfo.version;
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Text(
          "Version " + version,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white38),
          textAlign: TextAlign.center,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.black54,
        child: Container(
          margin: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _backButton(context),
                _textfield(),
              ]),
              _loadingWidget()
            ],
          ),
        ));
  }
}
