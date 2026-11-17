import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetFormPage extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;

  const PetFormPage({
    super.key,
    this.documentId,
    this.initialData,
  });

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  static const Color cream = Color(0xFFFFF5EA);
  static const Color coral = Color(0xFFF28C75);
  static const Color cocoa = Color(0xFF594438);
  static const Color softPink = Color(0xFFFFE4DA);

  final _formKey = GlobalKey<FormState>();

  final petNameController = TextEditingController();
  final otherBreedController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();

  String? animalType;
  String? gender;
  String? breed;
  String? vaccinationStatus;
  String? healthStatus;

  String ageUnit = 'Years';
  bool isLoading = false;

  final List<String> dogBreeds = [
    'Aspin',
    'Beagle',
    'Chihuahua',
    'Dachshund',
    'Golden Retriever',
    'German Shepherd',
    'Labrador Retriever',
    'Pomeranian',
    'Poodle',
    'Shih Tzu',
    'Siberian Husky',
    'Yorkshire Terrier',
    'Mixed Breed',
    'Other',
  ];

  final List<String> catBreeds = [
    'American Shorthair',
    'Bengal',
    'British Shorthair',
    'Maine Coon',
    'Persian',
    'Ragdoll',
    'Scottish Fold',
    'Siamese',
    'Sphynx',
    'Domestic Shorthair',
    'Domestic Longhair',
    'Mixed Breed',
    'Other',
  ];

  List<String> get currentBreeds {
    if (animalType == 'Dog') return dogBreeds;
    if (animalType == 'Cat') return catBreeds;
    return [];
  }

  bool get isEditing => widget.documentId != null;

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;

    if (data != null) {
      petNameController.text = data['petName']?.toString() ?? '';
      ageController.text = data['age']?.toString() ?? '';
      weightController.text = data['weight']?.toString() ?? '';

      ageUnit = data['ageUnit']?.toString() == 'Months'
          ? 'Months'
          : 'Years';

      final savedAnimalType = data['animalType']?.toString();

      if (savedAnimalType == 'Dog' || savedAnimalType == 'Cat') {
        animalType = savedAnimalType;
      }

      final savedGender = data['gender']?.toString();

      if (savedGender == 'Male' || savedGender == 'Female') {
        gender = savedGender;
      }

      final savedBreed = data['breed']?.toString();

      if (savedBreed != null && savedBreed.isNotEmpty) {
        if (currentBreeds.contains(savedBreed)) {
          breed = savedBreed;
        } else {
          breed = 'Other';
          otherBreedController.text = savedBreed;
        }
      }

      final savedVaccination =
          data['vaccinationStatus']?.toString();

      if ([
        'Vaccinated',
        'Not Vaccinated',
        'Partially Vaccinated',
      ].contains(savedVaccination)) {
        vaccinationStatus = savedVaccination;
      }

      final savedHealth = data['healthStatus']?.toString();

      if ([
        'Healthy',
        'Under Medication',
        'Needs Attention',
      ].contains(savedHealth)) {
        healthStatus = savedHealth;
      }
    }
  }

  @override
  void dispose() {
    petNameController.dispose();
    otherBreedController.dispose();
    ageController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: isError ? coral : Colors.green,
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
        backgroundColor: cocoa,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> savePet() async {
    if (!_formKey.currentState!.validate()) return;

    if (animalType == null ||
        gender == null ||
        breed == null ||
        vaccinationStatus == null ||
        healthStatus == null) {
      showMessage(
        'Please complete all required selections.',
        isError: true,
      );
      return;
    }

    if (breed == 'Other' &&
        otherBreedController.text.trim().isEmpty) {
      showMessage('Please enter the pet breed.', isError: true);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please log in again.', isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final selectedBreed = breed == 'Other'
          ? otherBreedController.text.trim()
          : breed!;

      final petData = {
        'petName': petNameController.text.trim(),
        'animalType': animalType,
        'breed': selectedBreed,
        'age': int.parse(ageController.text.trim()),
        'ageUnit': ageUnit,
        'gender': gender,
        'weight': double.parse(weightController.text.trim()),
        'vaccinationStatus': vaccinationStatus,
        'healthStatus': healthStatus,
      };

      final petsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets');

      if (isEditing) {
        await petsCollection
            .doc(widget.documentId)
            .update(petData);
      } else {
        await petsCollection.add({
          ...petData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      showMessage(
        isEditing
            ? 'Pet information updated successfully!'
            : 'Pet added successfully!',
      );

      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      showMessage(
        e.message ?? 'Something went wrong. Please try again.',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Unable to save pet information. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: cocoa,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: coral),
          filled: true,
          fillColor: cream,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: cocoa.withValues(alpha: 0.10),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: coral,
              width: 1.5,
            ),
          ),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            },
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: coral,
        ),
        style: const TextStyle(
          color: cocoa,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: coral),
          filled: true,
          fillColor: cream,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: cocoa.withValues(alpha: 0.10),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: coral,
              width: 1.5,
            ),
          ),
        ),
        hint: Text(
          hint,
          style: TextStyle(
            color: cocoa.withValues(alpha: 0.45),
            fontSize: 14,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an option';
              }
              return null;
            },
      ),
    );
  }

  Widget buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: softPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: coral, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: cocoa,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cocoa.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader(title, icon),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: cocoa,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Pet' : 'Add New Pet',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: cocoa,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: coral,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.pets_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing
                                  ? 'Update your pet'
                                  : 'Add a new furry friend!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Fill in the details to keep your pet information organized.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                buildSectionCard(
                  title: 'Pet Information',
                  icon: Icons.pets_rounded,
                  children: [
                    buildTextField(
                      label: 'Pet Name',
                      hint: 'Enter your pet name',
                      controller: petNameController,
                      icon: Icons.favorite_rounded,
                    ),

                    buildDropdown(
                      label: 'Animal Type',
                      hint: 'Select Animal Type',
                      icon: Icons.pets_rounded,
                      value: animalType,
                      items: const ['Dog', 'Cat'],
                      onChanged: (value) {
                        setState(() {
                          animalType = value;
                          breed = null;
                          otherBreedController.clear();
                        });
                      },
                    ),

                    buildDropdown(
                      label: 'Breed',
                      hint: animalType == null
                          ? 'Select Animal Type first'
                          : 'Select Breed',
                      icon: Icons.pets_rounded,
                      value: breed,
                      items: currentBreeds,
                      onChanged: (value) {
                        setState(() {
                          breed = value;
                          if (value != 'Other') {
                            otherBreedController.clear();
                          }
                        });
                      },
                      validator: (value) {
                        if (animalType == null) {
                          return 'Please select Animal Type first';
                        }
                        if (value == null || value.isEmpty) {
                          return 'Please select a breed';
                        }
                        return null;
                      },
                    ),

                    if (breed == 'Other')
                      buildTextField(
                        label: 'Specify Breed',
                        hint: 'Enter your pet breed',
                        controller: otherBreedController,
                        icon: Icons.edit_rounded,
                      ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: buildTextField(
                            label: 'Age',
                            hint: 'Enter age',
                            controller: ageController,
                            icon: Icons.cake_rounded,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Required';
                              }

                              final age = int.tryParse(value.trim());

                              if (age == null || age < 0) {
                                return 'Enter a valid age';
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: buildDropdown(
                            label: 'Age Unit',
                            hint: 'Unit',
                            icon: Icons.schedule_rounded,
                            value: ageUnit,
                            items: const ['Months', 'Years'],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => ageUnit = value);
                              }
                            },
                            validator: (value) => null,
                          ),
                        ),
                      ],
                    ),

                    buildDropdown(
                      label: 'Gender',
                      hint: 'Select Gender',
                      icon: Icons.pets_rounded,
                      value: gender,
                      items: const ['Male', 'Female'],
                      onChanged: (value) {
                        setState(() => gender = value);
                      },
                    ),

                    buildTextField(
                      label: 'Weight (kg)',
                      hint: 'Enter weight in kilograms',
                      controller: weightController,
                      icon: Icons.monitor_weight_rounded,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Weight is required';
                        }

                        final weight =
                            double.tryParse(value.trim());

                        if (weight == null || weight <= 0) {
                          return 'Enter a valid weight';
                        }

                        return null;
                      },
                    ),
                  ],
                ),

                buildSectionCard(
                  title: 'Health Information',
                  icon: Icons.health_and_safety_rounded,
                  children: [
                    buildDropdown(
                      label: 'Vaccination Status',
                      hint: 'Select Vaccination Status',
                      icon: Icons.vaccines_rounded,
                      value: vaccinationStatus,
                      items: const [
                        'Vaccinated',
                        'Not Vaccinated',
                        'Partially Vaccinated',
                      ],
                      onChanged: (value) {
                        setState(() {
                          vaccinationStatus = value;
                        });
                      },
                    ),

                    buildDropdown(
                      label: 'Health Status',
                      hint: 'Select Health Status',
                      icon: Icons.health_and_safety_rounded,
                      value: healthStatus,
                      items: const [
                        'Healthy',
                        'Under Medication',
                        'Needs Attention',
                      ],
                      onChanged: (value) {
                        setState(() {
                          healthStatus = value;
                        });
                      },
                    ),
                  ],
                ),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : savePet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coral,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save_rounded),
                              const SizedBox(width: 9),
                              Text(
                                isEditing ? 'Update Pet' : 'Save Pet',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                const Center(
                  child: Text(
                    'Made with ♥ for your furry friends',
                    style: TextStyle(
                      color: cocoa,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

