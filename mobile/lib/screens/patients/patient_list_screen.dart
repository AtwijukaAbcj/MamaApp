import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mama_app/services/database/database.dart';
import 'package:mama_app/screens/monitoring/monitoring_screen.dart';
import 'package:mama_app/theme/app_theme.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  final bool highRiskOnly;
  
  const PatientListScreen({
    super.key,
    this.highRiskOnly = false,
  });

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  String _searchQuery = '';
  bool _pregnantOnly = false;

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.highRiskOnly ? 'High Risk Cases' : 'My Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // Patient list
          Expanded(
            child: FutureBuilder<List<LocalPatient>>(
              future: _getFilteredPatients(database),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final patients = snapshot.data ?? [];
                
                if (patients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.highRiskOnly 
                            ? 'No high risk patients'
                            : 'No patients found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return _PatientCard(
                      patient: patient,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MonitoringScreen(patient: patient),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/patients/new');
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Register'),
      ),
    );
  }
  
  Future<List<LocalPatient>> _getFilteredPatients(AppDatabase database) async {
    List<LocalPatient> patients;
    
    if (widget.highRiskOnly) {
      patients = await database.getHighRiskPatients();
    } else if (_pregnantOnly) {
      patients = await database.getPregnantPatients();
    } else {
      patients = await database.getAllPatients();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      patients = patients.where((p) => 
        p.fullName.toLowerCase().contains(query) ||
        (p.phone?.contains(query) ?? false)
      ).toList();
    }
    
    return patients;
  }
  
  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter Patients',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Pregnant only'),
              value: _pregnantOnly,
              onChanged: (value) {
                setState(() => _pregnantOnly = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final LocalPatient patient;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gestationalWeeks = _calculateGestationalWeeks();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar / Risk indicator
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.riskColor(patient.latestRiskTier).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: patient.latestRiskTier == 'high'
                    ? const Icon(Icons.warning, color: AppTheme.riskHigh)
                    : Text(
                        patient.fullName.isNotEmpty 
                          ? patient.fullName[0].toUpperCase()
                          : '?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.riskColor(patient.latestRiskTier),
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Patient info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (patient.age != null)
                          _InfoChip(
                            icon: Icons.cake,
                            label: '${patient.age} yrs',
                          ),
                        if (patient.isPregnant) ...[
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.pregnant_woman,
                            label: gestationalWeeks != null 
                              ? '$gestationalWeeks wks' 
                              : 'Pregnant',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Obstetric history
                    Text(
                      'G${patient.gravida}P${patient.parity}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // Risk score and arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (patient.latestRiskScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.riskColor(patient.latestRiskTier),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(patient.latestRiskScore! * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  int? _calculateGestationalWeeks() {
    if (patient.pregnancyRegisteredAt == null || 
        patient.gestationalWeeksAtRegistration == null) {
      return null;
    }
    
    final weeksSinceReg = DateTime.now()
      .difference(patient.pregnancyRegisteredAt!)
      .inDays ~/ 7;
    
    return patient.gestationalWeeksAtRegistration! + weeksSinceReg;
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
