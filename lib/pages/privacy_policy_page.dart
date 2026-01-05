// lib/pages/privacy_policy_page.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy for Suvarnarj Group",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Last Updated: July 10, 2025",
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "1. Information We Collect",
              "We collect information that you provide directly to us when you:\n"
                  "- Register for our services\n"
                  "- Request a quote\n"
                  "- Schedule a cleaning service\n"
                  "- Contact our customer support\n"
                  "- Complete forms on our website\n"
                  "- Subscribe to newsletters or marketing communications\n\n"
                  "The types of information we may collect include:\n"
                  "- Personal identification information (name, email address, phone number, postal address)\n"
                  "- Location data (to determine service area and assign nearby professionals)\n"
                  "- Payment information (payment method details, transaction records)\n"
                  "- Property information relevant to cleaning services (type of space, size, special requirements)\n"
                  "- Service preferences and special instructions\n"
                  "- Communication records between you and our team",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "2. How We Use Your Information",
              "We may use the information we collect for various purposes, including to:\n"
                  "- Provide, maintain, and improve our services\n"
                  "- Process and complete transactions\n"
                  "- Send you service confirmations and updates\n"
                  "- Send administrative messages related to your account or services\n"
                  "- Respond to your comments, questions, and requests\n"
                  "- Communicate with you about products, services, offers, and events\n"
                  "- Provide customer support\n"
                  "- Monitor and analyze trends, usage, and activities\n"
                  "- Detect, investigate, and prevent fraudulent transactions and other illegal activities\n"
                  "- Comply with legal obligations",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "3. Information Sharing and Disclosure",
              "We may share your information with:\n"
                  "- Employees and cleaning professionals who need access to provide services\n"
                  "- Service providers who perform services on our behalf (payment processing, customer support, data analysis)\n"
                  "- Professional advisors, such as lawyers, auditors, and insurers\n"
                  "- Government authorities if required by law or to protect our rights\n\n"
                  "We do not sell or rent your personal information to third parties for their marketing purposes without your explicit consent.",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "4. Data Security",
              "We implement appropriate security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the Internet or electronic storage is 100% secure, and we cannot guarantee absolute security.",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "5. Your Data Protection Rights",
              "You have the right to:\n"
                  "- Access your personal data we hold\n"
                  "- Correct inaccurate personal data\n"
                  "- Request deletion of your personal data\n"
                  "- Object to processing of your personal data\n"
                  "- Request restriction of processing your personal data\n"
                  "- Request transfer of your personal data\n"
                  "- Withdraw consent where we rely on consent to process your personal data",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "6. Cookies and Tracking Technologies",
              "We may use cookies, web beacons, and similar tracking technologies on our website to collect information about your browsing activities. You can set your browser to refuse all or some browser cookies or to alert you when cookies are being sent. If you disable or refuse cookies, please note that some parts of our website may become inaccessible or not function properly.",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "7. Third-Party Links",
              "Our website may contain links to third-party websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services. We encourage you to read the privacy policy of every website you visit.",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "8. Children's Privacy",
              "Our services are not intended for individuals under the age of 18. We do not knowingly collect personal information from children under 18. If we learn we have collected or received personal information from a child under 18, we will delete that information. If you believe we might have any information from or about a child under 18, please contact us.",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "9. Changes to This Privacy Policy",
              "We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last Updated\" date. You are advised to review this Privacy Policy periodically for any changes.",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "10. Marketing Communications",
              "We may send you marketing communications about our products and services that we believe may be of interest to you. You can opt out of these communications at any time by:\n"
                  "- Following the unsubscribe instructions included in each marketing email\n"
                  "- Contacting us directly with your request",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "11. Data Retention",
              "We will retain your personal information only for as long as necessary to fulfill the purposes for which we collected it, including to satisfy any legal, accounting, or reporting requirements. To determine the appropriate retention period, we consider the amount, nature, and sensitivity of the data, the potential risk of harm from unauthorized use or disclosure, the purposes for which we process the data, and applicable legal requirements.",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "12. International Data Transfers",
              "Your information may be transferred to and processed in India where our servers are located. These countries may have data protection laws that differ from those in your country. By using our services, you consent to the transfer of your information to India and the processing of your information in India.",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildSection(
              "13. Contact Information",
              "If you have any questions or concerns about this Privacy Policy or our data practices, please contact us at:\n\n"
                  "Suvarnarj Group\n"
                  "Shop no.3, Rajdhani Complex, Near Shankar Maharaj Math, Balaji Nagar, Pune, Maharashtra 411043\n"
                  "+91 8485854972\n"
                  "contact@suvarnarajgroup.com\n\n"
                  "By using our services, you acknowledge that you have read and understood this Privacy Policy and agree to its terms.",
              colorScheme: colorScheme,
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, {required ColorScheme colorScheme}) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.sp,
              color: colorScheme.onSurface.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}