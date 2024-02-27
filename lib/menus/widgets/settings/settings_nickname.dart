import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:z1racing/base/components/common_textfield.dart';
import 'package:z1racing/base/exceptions/duplicated_name_exception.dart';
import 'package:z1racing/data/game_repository_impl.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';

class SettingsNickname extends StatefulWidget {
  // ignore: avoid_positional_boolean_parameters
  final Function(bool isLoading)? onLoading;

  const SettingsNickname({
    this.onLoading,
    super.key,
  });

  @override
  State<SettingsNickname> createState() => _SettingsNicknameState();
}

class _SettingsNicknameState extends State<SettingsNickname> {
  late String displayName;
  String? errorText;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    displayName = FirebaseFirestoreRepository.instance.currentUser?.name ?? '';
  }

  Widget _errorWidget() {
    if (errorText != null) {
      return Center(
        child: Text(
          errorText!,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container();
  }

  Widget _textfield() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 17),
          width: 100,
          child: Text(
            '${AppLocalizations.of(context)!.nickName}: ',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Container(
          width: 300,
          child: CommonTextfield(
            initialText: displayName,
            onSubmitted: _nameUpdated,
            maxLength: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _nameUpdated(String newName) async {
    if (newName.length > 3 &&
        newName.length <= 15 &&
        FirebaseFirestoreRepository.instance.currentUser?.name != newName) {
      try {
        setState(() {
          loading = true;
          widget.onLoading?.call(true);
        });
        await FirebaseFirestoreRepository.instance.updateName(newName);
        GameRepositoryImpl().reset();
      } on DuplicatedNameException catch (_) {
        setState(() {
          loading = false;
          errorText = AppLocalizations.of(context)!.errorDuplicateName;
          widget.onLoading?.call(false);
        });
        return;
      } on Exception catch (exc) {
        debugPrint(exc.toString());
      }
      setState(() {
        loading = false;
        errorText = null;
        widget.onLoading?.call(false);
      });
    } else {
      setState(() {
        loading = false;
        errorText = AppLocalizations.of(context)!.errorlengthName;
        widget.onLoading?.call(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _textfield(),
        _errorWidget(),
      ],
    );
  }
}
