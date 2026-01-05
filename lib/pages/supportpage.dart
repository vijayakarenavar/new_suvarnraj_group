// lib/pages/support_page.dart - COMPLETE SUPPORT PAGE (DARK/LIGHT MODE READY)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  int? _expandedFaqIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book a service?',
      'answer':
      'You can book a service by browsing our services, adding them to your cart, and proceeding to checkout.\n\nSelect your preferred date and time, fill in your details, and confirm your booking.',
    },
    {
      'question': 'What payment methods do you accept?',
      'answer':
      'We accept Cash on Delivery (COD) and online payment methods including Credit/Debit cards, UPI, Net Banking, and popular digital wallets.',
    },
    {
      'question': 'Can I reschedule my booking?',
      'answer':
      'Yes, you can reschedule your booking from the "My Bookings" section.\n\nNavigate to your booking details and click on the "Reschedule" button.',
    },
    {
      'question': 'How can I cancel my booking?',
      'answer':
      'Go to the "My Bookings" section, select the booking you want to cancel, and click on the "Cancel Booking" button.\n\nCancellation policy may apply.',
    },
    {
      'question': 'Are your service providers verified?',
      'answer':
      'Yes, all our service providers are thoroughly verified, trained, and background-checked professionals to ensure quality service.',
    },
    {
      'question': 'What is your cancellation policy?',
      'answer':
      'You can cancel your booking up to 2 hours before the scheduled time without any charges.\n\nCancellations within 2 hours may incur a small fee.',
    },
    {
      'question': 'How do I track my service provider?',
      'answer':
      'Once your service provider is assigned, you will receive notifications.\n\nYou can track their arrival in the "My Bookings" section.',
    },
    {
      'question': 'What if I\'m not satisfied with the service?',
      'answer':
      'Your satisfaction is our priority.\n\nIf you\'re not satisfied, please contact our support team immediately and we will resolve the issue or provide a refund as per our policy.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withOpacity(0.3),
      appBar: AppBar(
        title: Text(
          'Support & Help',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme),
            SizedBox(height: 3.h),
            _buildQuickActions(colorScheme),
            SizedBox(height: 3.h),
            _buildFaqSection(colorScheme),
            SizedBox(height: 3.h),
            _buildContactSection(colorScheme),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              FontAwesomeIcons.headset,
              size: 50,
              color: colorScheme.onPrimary,
            ),
            SizedBox(height: 2.h),
            Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'We\'re here 24/7 to assist you',
              style: TextStyle(
                fontSize: 13.5.sp,
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: FontAwesomeIcons.phone,
                title: 'Call Us',
                color: Colors.green, // brand color → keep
                onTap: () => _makePhoneCall(),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionCard(
                icon: FontAwesomeIcons.whatsapp,
                title: 'WhatsApp',
                color: Colors.teal, // brand color → keep
                onTap: () => _openWhatsApp(),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: FontAwesomeIcons.envelope,
                title: 'Email Us',
                color: Colors.blue, // brand color → keep
                onTap: () => _sendEmail(),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionCard(
                icon: FontAwesomeIcons.locationDot,
                title: 'Visit Us',
                color: Colors.orange, // brand color → keep
                onTap: () => _openLocation(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqs.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: colorScheme.outlineVariant),
            itemBuilder: (context, index) {
              final faq = _faqs[index];
              final isExpanded = _expandedFaqIndex == index;

              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  title: Text(
                    faq['question']!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.clip,
                  ),
                  trailing: Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: colorScheme.primary,
                  ),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedFaqIndex = expanded ? index : null;
                    });
                  },
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.08),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        faq['answer']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildContactItem(
                icon: FontAwesomeIcons.phone,
                title: 'Phone',
                subtitle: '+91 8485854972',
                color: Colors.green,
                onTap: () => _makePhoneCall(),
              ),
              SizedBox(height: 2.h),
              _buildContactItem(
                icon: FontAwesomeIcons.envelope,
                title: 'Email',
                subtitle: 'suvrnaraj1299@gmail.com',
                color: Colors.blue,
                onTap: () => _sendEmail(),
              ),
              SizedBox(height: 2.h),
              _buildContactItem(
                icon: FontAwesomeIcons.clock,
                title: 'Working Hours',
                subtitle: 'Mon - Sat: 9:00 AM - 6:00 PM',
                color: Colors.orange,
                onTap: null,
              ),
              SizedBox(height: 2.h),
              _buildContactItem(
                icon: FontAwesomeIcons.locationDot,
                title: 'Office Address',
                subtitle:
                '03, Rajdhani Complex, near Shankar Maharaj Math, KK Market, Balaji Nagar, Pune, Maharashtra 411043',
                color: Colors.red,
                onTap: () => _openLocation(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.clip,
                ),
                SizedBox(height: 0.3.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.6)),
        ],
      ),
    );
  }

  // ✅ FIXED: URL spaces removed
  Future<void> _openWhatsApp() async {
    const phoneNumber = '918485854972';
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber'); // ✅ No space
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Cannot open WhatsApp',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.error,
          colorText: Theme.of(context).colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open WhatsApp: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.error,
        colorText: Theme.of(context).colorScheme.onError,
      );
    }
  }

  Future<void> _openLocation() async {
    final address = '03, Rajdhani Complex, near Shankar Maharaj Math, KK Market, Balaji Nagar, Pune, Maharashtra 411043';
    final encodedAddress = Uri.encodeComponent(address);
    final Uri mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress'); // ✅ No space
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Cannot open maps',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.error,
          colorText: Theme.of(context).colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open location: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.error,
        colorText: Theme.of(context).colorScheme.onError,
      );
    }
  }

  Future<void> _makePhoneCall() async {
    const phoneNumber = '+918485854972';
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'Error',
          'Cannot make phone call',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.error,
          colorText: Theme.of(context).colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to make call: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.error,
        colorText: Theme.of(context).colorScheme.onError,
      );
    }
  }

  Future<void> _sendEmail() async {
    const email = 'suvrnaraj1299@gmail.com';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support%20Request',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        Get.snackbar(
          'Error',
          'Cannot open email app',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.error,
          colorText: Theme.of(context).colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send email: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.error,
        colorText: Theme.of(context).colorScheme.onError,
      );
    }
  }
}