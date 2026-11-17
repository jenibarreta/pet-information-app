import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  static const Color cream = Color(0xFFFFF5EA);
  static const Color coral = Color(0xFFF28C75);
  static const Color cocoa = Color(0xFF594438);
  static const Color softPink = Color(0xFFFFE8DF);

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: cocoa,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage('Please complete all password fields.');
      return;
    }

    if (newPassword.length < 6) {
      showMessage('New password must be at least 6 characters.');
      return;
    }

    if (newPassword != confirmPassword) {
      showMessage('New passwords do not match.');
      return;
    }

    if (currentPassword == newPassword) {
      showMessage(
        'New password must be different from current password.',
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      showMessage('No signed-in account found.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      if (mounted) {
        showMessage('Password changed successfully!');
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Your current password is incorrect.';
          break;
        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;
        case 'requires-recent-login':
          message = 'Please log in again before changing your password.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        default:
          message = e.message ?? 'Unable to change password.';
      }

      if (mounted) showMessage(message);
    } catch (e) {
      if (mounted) {
        showMessage('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: coral,
            ),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                color: cocoa,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: cocoa),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: cocoa),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: coral,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  Widget passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          color: cocoa,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: coral,
            size: 21,
          ),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: cocoa,
              size: 21,
            ),
          ),
          filled: true,
          fillColor: cream,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: coral,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: cocoa,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: cream,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ACCOUNT PROFILE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: softPink,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 37,
                      backgroundColor: coral,
                      child: Icon(
                        Icons.person_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Pet Owner Account',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: cocoa,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Manage your account information',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: cream,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          color: coral,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            user?.email ?? 'No email available',
                            style: const TextStyle(
                              color: cocoa,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // CHANGE PASSWORD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: softPink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: coral,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: sectionTitle(
                          'Change Password',
                          'Keep your account secure',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  passwordField(
                    label: 'Current Password',
                    controller: currentPasswordController,
                    obscure: obscureCurrent,
                    onToggle: () {
                      setState(() {
                        obscureCurrent = !obscureCurrent;
                      });
                    },
                  ),

                  passwordField(
                    label: 'New Password',
                    controller: newPasswordController,
                    obscure: obscureNew,
                    onToggle: () {
                      setState(() {
                        obscureNew = !obscureNew;
                      });
                    },
                  ),

                  passwordField(
                    label: 'Confirm New Password',
                    controller: confirmPasswordController,
                    obscure: obscureConfirm,
                    onToggle: () {
                      setState(() {
                        obscureConfirm = !obscureConfirm;
                      });
                    },
                  ),

                  const SizedBox(height: 5),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : changePassword,
                      icon: isLoading
                          ? const SizedBox(
                              height: 19,
                              width: 19,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 20,
                            ),
                      label: Text(
                        isLoading ? 'Updating...' : 'Update Password',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coral,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // LOGOUT
            const Divider(
              color: Color(0xFFE5D8CC),
              thickness: 1,
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: logout,
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 20,
                ),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cocoa,
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFFE5D8CC),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

