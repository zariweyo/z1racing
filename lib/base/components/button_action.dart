import 'package:flutter/material.dart';
import 'package:z1racing/domain/repositories/firebase_firestore_repository.dart';

class ButtonActions extends StatelessWidget {
  final Function()? onTap;
  final Widget? child;

  const ButtonActions({super.key, this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    final color = FirebaseFirestoreRepository.instance.avatarColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.shade300,
              color.shade400,
            ], // Colores de degradado
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 5.0,
            ),
          ],
          borderRadius: BorderRadius.circular(10), // Esquinas redondeadas
        ),
        child: child,
      ),
    );
  }
}
