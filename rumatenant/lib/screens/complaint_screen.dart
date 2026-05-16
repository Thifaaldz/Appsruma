import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/complaint_provider.dart';
import '../models/complaint.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ComplaintProvider>().fetchComplaints());
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = context.watch<ComplaintProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
      ),
      body: complaintProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: complaintProvider.complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = complaintProvider.complaints[index];
                      return ListTile(
                        title: Text(complaint.title),
                        subtitle: Text(complaint.description),
                        trailing: Text(complaint.status),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
                      TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final complaint = Complaint(
                            id: 0,
                            tenantId: 1, // Default for now
                            title: _titleController.text,
                            description: _descController.text,
                            status: 'pending',
                          );
                          if (await complaintProvider.addComplaint(complaint)) {
                            _titleController.clear();
                            _descController.clear();
                          }
                        },
                        child: const Text('Submit Complaint'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
