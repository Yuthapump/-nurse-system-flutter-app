import 'package:flutter/material.dart';

class LeaveRequestPage extends StatelessWidget {
  const LeaveRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reasonController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Request')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reason for Leave'),
            TextField(controller: reasonController, maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Leave request submitted.")),
                );
              },
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
