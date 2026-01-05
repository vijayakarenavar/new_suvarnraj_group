import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controller/profile_controller.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  final _formKey = GlobalKey<FormState>();
  bool hasChanges = false;

  final ProfileController profileCtrl = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: profileCtrl.name.value);
    emailController = TextEditingController(text: profileCtrl.email.value);
    phoneController = TextEditingController(text: profileCtrl.phone.value);

    nameController.addListener(_checkChanges);
    emailController.addListener(_checkChanges);
    phoneController.addListener(_checkChanges);
  }

  void _checkChanges() {
    setState(() {
      hasChanges = nameController.text.trim() != profileCtrl.name.value.trim() ||
          emailController.text.trim() != profileCtrl.email.value.trim() ||
          phoneController.text.trim() != profileCtrl.phone.value.trim();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (!hasChanges) {
      Get.snackbar(
        "No Changes",
        "No changes were made to save",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    final success = await profileCtrl.updateProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
    );

    if (success) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    final displayName = nameController.text.isNotEmpty
                        ? nameController.text
                        : profileCtrl.name.value;
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'G',
                        style: TextStyle(
                          fontSize: 40,
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surface, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: colorScheme.onPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Center(
              child: Text(
                "Tap to change photo",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Personal Info Section
            _buildSectionTitle("Personal Information", colorScheme),
            SizedBox(height: 1.h),

            _buildTextField(
              controller: nameController,
              label: "Full Name",
              hint: "Enter your full name",
              icon: Icons.person,
              colorScheme: colorScheme,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]*$')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Name is required";
                }
                final trimmed = value.trim();
                if (trimmed.length < 3) {
                  return "Name must be at least 3 characters";
                }
                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed)) {
                  return "Name can only contain letters and spaces";
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),

            _buildTextField(
              controller: emailController,
              label: "Email Address",
              hint: "Enter your email",
              icon: Icons.email,
              colorScheme: colorScheme,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Email is required";
                }
                if (!GetUtils.isEmail(value.trim())) {
                  return "Enter a valid email";
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),

            _buildTextField(
              controller: phoneController,
              label: "Phone Number",
              hint: "Enter your 10-digit mobile number",
              icon: Icons.phone,
              colorScheme: colorScheme,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Phone number is required";
                }
                final trimmed = value.trim();
                if (trimmed.length != 10) {
                  return "Phone number must be 10 digits";
                }
                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed)) {
                  return "Phone number must start with 6, 7, 8, or 9";
                }
                return null;
              },
            ),
            SizedBox(height: 4.h),

            // Save Button
            Obx(() {
              return ElevatedButton(
                onPressed: profileCtrl.isLoading.value || !hasChanges
                    ? null
                    : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasChanges ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1),
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: profileCtrl.isLoading.value
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: colorScheme.onPrimary,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  "Save Changes",
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
            SizedBox(height: 2.h),

            // Cancel Button
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                side: BorderSide(color: colorScheme.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: colorScheme.primary, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.8.h,
          ),
          labelStyle: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
          hintStyle: TextStyle(
            fontSize: 11.sp,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        style: TextStyle(
          fontSize: 12.sp,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}