import 'package:flutter/material.dart';
import 'package:z1racing/base/components/common_textfield.dart';
import 'package:z1racing/repositories/firebase_auth_repository.dart';
import 'package:z1racing/repositories/firebase_firestore_repository.dart';

class MenuSettings extends StatefulWidget {
  static Future open({required BuildContext context}) {
    return showDialog(context: context, builder: ((ctx) => MenuSettings()));
  }

  @override
  State<MenuSettings> createState() => _MenuSettingsState();
}

class _MenuSettingsState extends State<MenuSettings> {
  late String displayName;
  bool loading = false;

  @override
  initState() {
    super.initState();
    displayName = FirebaseAuthRepository().currentUser?.displayName ?? "";
  }

  _nameUpdated(String newName) async {
    if (newName.length > 3 &&
        newName.length <= 15 &&
        FirebaseFirestoreRepository().currentUser?.displayName != newName) {
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
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: EdgeInsets.only(top: 17),
          child: Text("Nickname: ",
              style: Theme.of(context).textTheme.bodyMedium)),
      Expanded(
          child: CommonTextfield(
              initialText: displayName, onSubmitted: _nameUpdated))
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
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _backButton(context),
              Expanded(
                  child: ListView(
                children: [_textfield(), _loadingWidget()],
              )),
            ])));
  }
}
