import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tenant_provider.dart';
import '../models/tenant.dart';

class TenantScreen extends StatefulWidget {
  const TenantScreen({super.key});

  @override
  State<TenantScreen> createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TenantProvider>().fetchTenants());
  }

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tenants'),
      ),
      body: tenantProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tenantProvider.tenants.length,
              itemBuilder: (context, index) {
                final tenant = tenantProvider.tenants[index];
                return ListTile(
                  title: Text('Tenant ID: ${tenant.userId}'),
                  subtitle: Text('Phone: ${tenant.phone} - Room ID: ${tenant.roomId}'),
                );
              },
            ),
    );
  }
}
