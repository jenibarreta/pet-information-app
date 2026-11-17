import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pets_page.dart';
import 'account_settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color cream = Color(0xFFFFF5EA);
  static const Color coral = Color(0xFFF28C75);
  static const Color cocoa = Color(0xFF594438);

  int selectedIndex = 0;

  final List<String> pageTitles = [
    'Pet Information App',
    'My Pets',
    'Account Settings',
  ];

  void navigateToPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardContent(onNavigate: navigateToPage),
      const PetsPage(),
      const AccountSettingsPage(),
    ];

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: Text(
          pageTitles[selectedIndex],
          style: const TextStyle(
            color: cocoa,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: cream,
        elevation: 0,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: coral.withValues(alpha: 0.18),
        selectedIndex: selectedIndex,
        onDestinationSelected: navigateToPage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: cocoa),
            selectedIcon: Icon(Icons.dashboard_rounded, color: coral),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined, color: cocoa),
            selectedIcon: Icon(Icons.pets_rounded, color: coral),
            label: 'My Pets',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: cocoa),
            selectedIcon: Icon(Icons.person_rounded, color: coral),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

// DASHBOARD CONTENT

class DashboardContent extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const DashboardContent({
    super.key,
    required this.onNavigate,
  });

  static const Color cream = Color(0xFFFFF5EA);
  static const Color coral = Color(0xFFF28C75);
  static const Color cocoa = Color(0xFF594438);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('No signed-in account found.'),
      );
    }

    final petsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: petsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: coral),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Unable to load pet information.'),
          );
        }

        final pets = snapshot.data?.docs ?? [];
        final totalPets = pets.length;

        final dogCount = pets.where((pet) {
          final type = pet.data()['animalType'] ?? '';
          return type.toString().trim().toLowerCase() == 'dog';
        }).length;

        final catCount = pets.where((pet) {
          final type = pet.data()['animalType'] ?? '';
          return type.toString().trim().toLowerCase() == 'cat';
        }).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: coral,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: coral.withValues(alpha: 0.20),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '🐾',
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Hello, Pet Owner!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      user.email ?? 'Welcome back!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'Keep your lovely pets organized and cared for.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Pet Overview
              const Text(
                'Pet Overview',
                style: TextStyle(
                  color: cocoa,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A quick look at your pet records.',
                style: TextStyle(
                  color: cocoa.withValues(alpha: 0.65),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Pets',
                      count: totalPets,
                      emoji: '🐾',
                      color: coral,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      title: 'Dogs',
                      count: dogCount,
                      emoji: '🐶',
                      color: cocoa,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      title: 'Cats',
                      count: catCount,
                      emoji: '🐱',
                      color: const Color(0xFFD69A48),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Quick Access
              const Text(
                'Quick Access',
                style: TextStyle(
                  color: cocoa,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Go directly to the sections you need.',
                style: TextStyle(
                  color: cocoa.withValues(alpha: 0.65),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _QuickAccessCard(
                      title: 'My Pets',
                      subtitle: 'Manage pet records',
                      emoji: '🐾',
                      onTap: () => onNavigate(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAccessCard(
                      title: 'Account Settings',
                      subtitle: 'Manage your account',
                      emoji: '⚙️',
                      onTap: () => onNavigate(2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Empty State / Pet Message
              if (totalPets == 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '🐾',
                        style: TextStyle(fontSize: 42),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Your pet family starts here!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cocoa,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Add your first pet in the My Pets section.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: cream,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            '❤️',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your pets are all in one place!',
                              style: TextStyle(
                                color: cocoa,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Manage their information anytime in My Pets.',
                              style: TextStyle(
                                color: Colors.grey,
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
            ],
          ),
        );
      },
    );
  }
}

// STATISTIC CARD

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final String emoji;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.emoji,
    required this.color,
  });

  static const Color cocoa = Color(0xFF594438);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 27),
          ),
          const SizedBox(height: 5),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: cocoa,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// QUICK ACCESS CARD

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.onTap,
  });

  static const Color cream = Color(0xFFFFF5EA);
  static const Color coral = Color(0xFFF28C75);
  static const Color cocoa = Color(0xFF594438);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 145),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: coral.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  color: cocoa,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: cocoa.withValues(alpha: 0.65),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Text(
                    'Open',
                    style: TextStyle(
                      color: coral,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: coral,
                    size: 15,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

