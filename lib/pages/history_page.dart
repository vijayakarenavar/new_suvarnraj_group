import 'package:flutter/material.dart';
import '../api/api_contact.dart';
import '../models/contact_model.dart';

class HistoryPage extends StatefulWidget {
  final String email;
  const HistoryPage({super.key, required this.email});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<ContactHistory>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = ApiContact.getHistory(widget.email) as Future<List<ContactHistory>>;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Enquiry History"),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: FutureBuilder<List<ContactHistory>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colorScheme.primary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No history found",
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              ),
            );
          }

          final historyList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];
              return Card(
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name: ${item.firstName ?? '-'}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("Email: ${item.email ?? '-'}", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.9))),
                      Text("Mobile: ${item.mobile ?? '-'}", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.9))),
                      Text("Service: ${item.service ?? '-'}", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.9))),
                      Text("City: ${item.city ?? '-'}", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.9))),
                      Text("State: ${item.state ?? '-'}", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.9))),
                      Text("Area: ${item.area ?? '-'}", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.9))),
                      Text("Date: ${item.date ?? '-'}", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.9))),
                      Text("Time: ${item.time ?? '-'}", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.9))),
                      Text(
                        "Inspection: ${item.orderInspection == '1' ? "Yes" : "No"}",
                        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.9)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Message: ${item.message ?? '-'}",
                        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}