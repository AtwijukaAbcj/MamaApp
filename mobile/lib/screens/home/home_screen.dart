import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mama_app/services/database/database.dart';
import 'package:mama_app/services/sync/sync_service.dart';
import 'package:mama_app/providers/auth_provider.dart';
import 'package:mama_app/screens/patients/patient_list_screen.dart';
import 'package:mama_app/screens/devices/device_list_screen.dart';
import 'package:mama_app/screens/monitoring/quick_monitor_screen.dart';
import 'package:mama_app/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final database = ref.watch(databaseProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MamaApp'),
        actions: [
          // Sync indicator
          IconButton(
            onPressed: syncStatus.isSyncing ? null : () {
              ref.read(syncStatusProvider.notifier).sync();
            },
            icon: syncStatus.isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Badge(
                  isLabelVisible: syncStatus.pendingCount > 0,
                  label: Text('${syncStatus.pendingCount}'),
                  child: Icon(
                    syncStatus.isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: syncStatus.isOnline ? Colors.green : Colors.grey,
                  ),
                ),
          ),
          // Profile menu
          PopupMenuButton<dynamic>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
              PopupMenuItem(
                child: authState.when(
                  data: (user) => Text(user?.name ?? 'User'),
                  loading: () => const Text('Loading...'),
                  error: (_, __) => const Text('Error'),
                ),
                enabled: false,
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () {
                  ref.read(authActionsProvider).logout();
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              authState.when(
                                data: (user) => Text(
                                  'Welcome, ${user?.name ?? "Health Worker"}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                loading: () => const Text('Loading...'),
                                error: (_, __) => const Text('Error'),
                              ),
                              Text(
                                'Community Health Worker',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add_chart,
                    title: 'Quick Monitor',
                    subtitle: 'Record vitals now',
                    color: Theme.of(context).primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuickMonitorScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.bluetooth,
                    title: 'Devices',
                    subtitle: 'Connect BLE',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DeviceListScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Stats
            FutureBuilder(
              future: _getStats(database),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {};
                return Row(
                  children: [
                    _StatCard(
                      icon: Icons.people,
                      value: '${stats['totalPatients'] ?? 0}',
                      label: 'Patients',
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      icon: Icons.pregnant_woman,
                      value: '${stats['pregnantPatients'] ?? 0}',
                      label: 'Pregnant',
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      icon: Icons.warning,
                      value: '${stats['highRisk'] ?? 0}',
                      label: 'High Risk',
                      valueColor: AppTheme.riskHigh,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Main menu
            Text(
              'Menu',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            _MenuTile(
              icon: Icons.people,
              title: 'My Patients',
              subtitle: 'View and manage assigned patients',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PatientListScreen()),
                );
              },
            ),
            _MenuTile(
              icon: Icons.person_add,
              title: 'Register Patient',
              subtitle: 'Add a new pregnant woman',
              onTap: () {
                Navigator.pushNamed(context, '/patients/new');
              },
            ),
            _MenuTile(
              icon: Icons.warning_amber,
              title: 'High Risk Cases',
              subtitle: 'View patients needing attention',
              badge: FutureBuilder(
                future: database.getHighRiskPatients(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.riskHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientListScreen(highRiskOnly: true),
                  ),
                );
              },
            ),
            _MenuTile(
              icon: Icons.local_hospital,
              title: 'Referrals',
              subtitle: 'View pending and completed referrals',
              onTap: () {
                Navigator.pushNamed(context, '/referrals');
              },
            ),
            _MenuTile(
              icon: Icons.medical_services,
              title: 'Device Management',
              subtitle: 'Pair and assign BLE devices',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceListScreen()),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Sync status
            if (syncStatus.pendingCount > 0)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.sync_problem, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${syncStatus.pendingCount} records pending sync',
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                      if (!syncStatus.isOnline)
                        const Chip(
                          label: Text('Offline'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<Map<String, int>> _getStats(AppDatabase database) async {
    final allPatients = await database.getAllPatients();
    final pregnantPatients = await database.getPregnantPatients();
    final highRisk = await database.getHighRiskPatients();
    
    return {
      'totalPatients': allPatients.length,
      'pregnantPatients': pregnantPatients.length,
      'highRisk': highRisk.length,
    };
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? badge;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null) ...[
              badge!,
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
