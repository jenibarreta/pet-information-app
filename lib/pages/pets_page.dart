import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pet_form_page.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({super.key});

  static const Color cream = Color(0xFFFFF5EA);
  static const Color coral = Color(0xFFF28C75);
  static const Color cocoa = Color(0xFF594438);
  static const Color gold = Color(0xFFD69A48);

  String getPetEmoji(String animalType) {
    switch (animalType.trim().toLowerCase()) {
      case 'dog':
        return '🐶';
      case 'cat':
        return '🐱';
      default:
        return '🐾';
    }
  }

  void showPetSnackBar(
    BuildContext context, {
    required String message,
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: cocoa,
          elevation: 4,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                color: isSuccess
                    ? const Color(0xFF9ED6A5)
                    : coral,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void addPet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PetFormPage(),
      ),
    );
  }

  void editPet(
    BuildContext context,
    String documentId,
    Map<String, dynamic> pet,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PetFormPage(
          documentId: documentId,
          initialData: pet,
        ),
      ),
    );
  }

  Future<bool> confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Delete Pet',
          style: TextStyle(
            color: cocoa,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this pet record?',
          style: TextStyle(
            color: cocoa,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: cocoa),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    return confirm == true;
  }

  Future<bool> deletePet(
    BuildContext context,
    String documentId,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(documentId)
          .delete();

      if (context.mounted) {
        showPetSnackBar(
          context,
          message: 'Pet deleted successfully!',
          isSuccess: true,
        );
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        showPetSnackBar(
          context,
          message: 'Unable to delete pet. Please try again.',
          isSuccess: false,
        );
      }

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    final petsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: cream,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: petsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: coral),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load pet records.',
                style: TextStyle(color: cocoa),
              ),
            );
          }

          final pets = snapshot.data?.docs ?? [];
          final hasPets = pets.isNotEmpty;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape =
                  constraints.maxWidth > constraints.maxHeight;

              final horizontalPadding = isLandscape ? 28.0 : 20.0;
              final headerPadding = isLandscape ? 15.0 : 20.0;
              final headerTop = isLandscape ? 8.0 : 12.0;
              final headerBottom = isLandscape ? 12.0 : 18.0;
              final headerTitleSize = isLandscape ? 19.0 : 21.0;
              final headerIconSize = isLandscape ? 52.0 : 65.0;

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  headerTop,
                  horizontalPadding,
                  90,
                ),
                children: [
                  // PET FAMILY HEADER
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(headerPadding),
                    decoration: BoxDecoration(
                      color: coral,
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: [
                        BoxShadow(
                          color: coral.withValues(alpha: 0.16),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Pet Family 🐾',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 7),
                              Text(
                                'All your lovely companions in one place.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: headerIconSize,
                          height: headerIconSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '🐶',
                              style: TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isLandscape ? 12 : 18),

                  // TOTAL PETS
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: isLandscape ? 11 : 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            color: cream,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Center(
                            child: Text(
                              '🐾',
                              style: TextStyle(fontSize: 23),
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        const Expanded(
                          child: Text(
                            'Total Registered Pets',
                            style: TextStyle(
                              color: cocoa,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          pets.length.toString(),
                          style: const TextStyle(
                            color: coral,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isLandscape ? 16 : 24),

                  // EMPTY STATE
                  if (!hasPets)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: coral.withValues(alpha: 0.13),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 125,
                            height: 125,
                            decoration: const BoxDecoration(
                              color: cream,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '🐶🐱',
                                style: TextStyle(fontSize: 48),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Your pet family is waiting!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: cocoa,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            'You have not added any pets yet. '
                            'Register your first dog or cat and '
                            'keep their information organized.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: cocoa.withValues(alpha: 0.65),
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 23),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => addPet(context),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Your First Pet'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: coral,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 17),
                          const Text(
                            'Every pet deserves a little extra care. ❤️',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // PET RECORDS
                  if (hasPets)
                    ...pets.map((document) {
                      final pet = document.data();

                      final petName =
                          pet['petName']?.toString() ?? 'Unnamed Pet';
                      final animalType =
                          pet['animalType']?.toString() ?? 'Pet';
                      final breed =
                          pet['breed']?.toString() ?? 'Not specified';
                      final age =
                          pet['age']?.toString() ?? 'Not specified';
                      final ageUnit =
                          pet['ageUnit']?.toString() ?? 'Years';
                      final gender =
                          pet['gender']?.toString() ?? 'Not specified';
                      final weight =
                          pet['weight']?.toString() ?? 'Not specified';
                      final vaccination =
                          pet['vaccinationStatus']?.toString() ??
                              'Not specified';
                      final health =
                          pet['healthStatus']?.toString() ??
                              'Not specified';

                      final emoji = getPetEmoji(animalType);

                      return Dismissible(
                        key: ValueKey(document.id),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction ==
                              DismissDirection.startToEnd) {
                            editPet(
                              context,
                              document.id,
                              pet,
                            );
                            return false;
                          }

                          if (direction ==
                              DismissDirection.endToStart) {
                            final confirmed =
                                await confirmDelete(context);

                            if (!confirmed) return false;

                            return await deletePet(
                              context,
                              document.id,
                            );
                          }

                          return false;
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: coral,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerLeft,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(height: 5),
                              Text(
                                'EDIT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(height: 5),
                              Text(
                                'DELETE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: EdgeInsets.all(
                            isLandscape ? 14 : 17,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: coral.withValues(alpha: 0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cocoa.withValues(alpha: 0.035),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 65,
                                    height: 65,
                                    decoration: BoxDecoration(
                                      color: cream,
                                      borderRadius:
                                          BorderRadius.circular(18),
                                    ),
                                    child: Center(
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(
                                          fontSize: 36,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          petName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: cocoa,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '$animalType • $breed',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: cocoa,
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              const Divider(
                                color: Color(0xFFF2E7DD),
                                height: 1,
                              ),
                              const SizedBox(height: 13),

                              const Text(
                                'PET INFORMATION',
                                style: TextStyle(
                                  color: cocoa,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),

                              const SizedBox(height: 11),

                              _PetInfoRow(
                                icon: Icons.cake_outlined,
                                label: 'Age',
                                value: '$age $ageUnit',
                              ),
                              _PetInfoRow(
                                icon: Icons.pets_rounded,
                                label: 'Gender',
                                value: gender,
                              ),
                              _PetInfoRow(
                                icon: Icons.monitor_weight_outlined,
                                label: 'Weight',
                                value: '$weight kg',
                              ),

                              const SizedBox(height: 13),

                              const Text(
                                'HEALTH INFORMATION',
                                style: TextStyle(
                                  color: cocoa,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),

                              const SizedBox(height: 11),

                              _PetInfoRow(
                                icon: Icons.vaccines_rounded,
                                label: 'Vaccination Status',
                                value: vaccination,
                              ),
                              _PetInfoRow(
                                icon: Icons.health_and_safety_rounded,
                                label: 'Health Status',
                                value: health,
                              ),

                              const SizedBox(height: 10),

                              const Row(
                                children: [
                                  Icon(
                                    Icons.swipe_rounded,
                                    size: 16,
                                    color: coral,
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Swipe right to edit • left to delete',
                                      style: TextStyle(
                                        color: cocoa,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          );
        },
      ),

      floatingActionButton:
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: petsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            backgroundColor: coral,
            foregroundColor: Colors.white,
            elevation: 3,
            onPressed: () => addPet(context),
            child: const Icon(Icons.add_rounded, size: 28),
          );
        },
      ),
    );
  }
}

class _PetInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PetInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color cocoa = Color(0xFF594438);
  static const Color coral = Color(0xFFF28C75);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: coral,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: cocoa,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: cocoa,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


