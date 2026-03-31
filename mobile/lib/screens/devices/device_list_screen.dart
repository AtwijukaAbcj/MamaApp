import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mama_app/services/database/database.dart';
import 'package:mama_app/services/ble/ble_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;

class DeviceListScreen extends ConsumerStatefulWidget {
  const DeviceListScreen({super.key});

  @override
  ConsumerState<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends ConsumerState<DeviceListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isScanning = false;
  List<DiscoveredDevice> _discoveredDevices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Devices'),
            Tab(text: 'Scan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyDevicesTab(),
          _ScanTab(
            isScanning: _isScanning,
            discoveredDevices: _discoveredDevices,
            onStartScan: _startScan,
            onStopScan: _stopScan,
            onConnect: _connectDevice,
          ),
        ],
      ),
    );
  }

  Future<void> _startScan() async {
    // Request permissions
    final permissions = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    
    if (permissions.values.any((p) => p.isDenied)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth permissions required')),
      );
      return;
    }
    
    // Check Bluetooth state
    final bleService = ref.read(bleServiceProvider);
    if (!await bleService.isBluetoothReady()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable Bluetooth')),
      );
      return;
    }
    
    setState(() {
      _isScanning = true;
      _discoveredDevices = [];
    });
    
    // Start generic scan (includes Wearfit-style devices)
    bleService.startGenericScan().listen(
      (devices) {
        if (mounted) {
          setState(() => _discoveredDevices = devices);
        }
      },
      onDone: () {
        if (mounted) {
          setState(() => _isScanning = false);
        }
      },
    );
  }

  Future<void> _stopScan() async {
    final bleService = ref.read(bleServiceProvider);
    await bleService.stopScan();
    setState(() => _isScanning = false);
  }

  Future<void> _connectDevice(DiscoveredDevice device) async {
    final bleService = ref.read(bleServiceProvider);
    final database = ref.read(databaseProvider);
    
    // Show connecting dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connecting'),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text('Connecting to ${device.name}...')),
          ],
        ),
      ),
    );
    
    try {
      final connected = await bleService.connect(device.device);
      
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      
      if (connected) {
        // Register device in local database
        await database.insertDevice(DevicesCompanion.insert(
          id: const Uuid().v4(),
          deviceHardwareId: device.device.remoteId.str,
          deviceName: device.name,
          deviceType: device.type.code,
          createdAt: DateTime.now(),
        ));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to ${device.name}')),
        );
        
        // Switch to My Devices tab
        _tabController.animateTo(0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _MyDevicesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);
    
    return FutureBuilder<List<LocalDevice>>(
      future: database.getAllDevices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final devices = snapshot.data ?? [];
        
        if (devices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bluetooth_disabled,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text('No devices registered'),
                const SizedBox(height: 8),
                const Text(
                  'Go to the Scan tab to pair devices',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return _DeviceCard(device: device);
          },
        );
      },
    );
  }
}

class _DeviceCard extends ConsumerWidget {
  final LocalDevice device;

  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _DeviceTypeIcon(type: device.deviceType),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.deviceName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        device.deviceHardwareId,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Battery indicator
                if (device.batteryLevel != null)
                  _BatteryIndicator(level: device.batteryLevel!),
              ],
            ),
            const SizedBox(height: 12),
            
            // Assignment status
            FutureBuilder<LocalPatient?>(
              future: device.assignedPatientId != null
                ? database.getPatientById(device.assignedPatientId!)
                : Future.value(null),
              builder: (context, snapshot) {
                final patient = snapshot.data;
                
                if (patient != null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Assigned to ${patient.fullName}',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _unassignDevice(context, ref),
                          child: const Text('Unassign'),
                        ),
                      ],
                    ),
                  );
                }
                
                return OutlinedButton.icon(
                  onPressed: () => _showAssignDialog(context, ref),
                  icon: const Icon(Icons.link),
                  label: const Text('Assign to Patient'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context, WidgetRef ref) {
    final database = ref.read(databaseProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Assign Device to Patient',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<LocalPatient>>(
                future: database.getPregnantPatients(),
                builder: (context, snapshot) {
                  final patients = snapshot.data ?? [];
                  
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(patient.fullName[0]),
                        ),
                        title: Text(patient.fullName),
                        subtitle: Text('G${patient.gravida}P${patient.parity}'),
                        onTap: () async {
                          await database.assignDeviceToPatient(device.id, patient.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Device assigned to ${patient.fullName}')),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unassignDevice(BuildContext context, WidgetRef ref) async {
    final database = ref.read(databaseProvider);
    await database.assignDeviceToPatient(device.id, ''); // Clear assignment
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device unassigned')),
      );
    }
  }
}

class _ScanTab extends StatelessWidget {
  final bool isScanning;
  final List<DiscoveredDevice> discoveredDevices;
  final VoidCallback onStartScan;
  final VoidCallback onStopScan;
  final void Function(DiscoveredDevice) onConnect;

  const _ScanTab({
    required this.isScanning,
    required this.discoveredDevices,
    required this.onStartScan,
    required this.onStopScan,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scan button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: isScanning ? onStopScan : onStartScan,
            icon: Icon(isScanning ? Icons.stop : Icons.bluetooth_searching),
            label: Text(isScanning ? 'Stop Scanning' : 'Start Scan'),
          ),
        ),
        
        if (isScanning)
          const LinearProgressIndicator(),
        
        // Discovered devices
        Expanded(
          child: discoveredDevices.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isScanning 
                        ? 'Scanning for devices...'
                        : 'Tap "Start Scan" to find devices',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: discoveredDevices.length,
                itemBuilder: (context, index) {
                  final device = discoveredDevices[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: _DeviceTypeIcon(type: device.type.code),
                      title: Text(device.name),
                      subtitle: Text(device.type.displayName),
                      trailing: ElevatedButton(
                        onPressed: () => onConnect(device),
                        child: const Text('Connect'),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}

class _DeviceTypeIcon extends StatelessWidget {
  final String type;

  const _DeviceTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'bp_monitor':
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case 'pulse_oximeter':
        icon = Icons.air;
        color = Colors.blue;
        break;
      case 'thermometer':
        icon = Icons.thermostat;
        color = Colors.orange;
        break;
      case 'fetal_doppler':
        icon = Icons.child_friendly;
        color = Colors.pink;
        break;
      default:
        icon = Icons.bluetooth;
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _BatteryIndicator extends StatelessWidget {
  final int level;

  const _BatteryIndicator({required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    if (level > 80) {
      color = Colors.green;
      icon = Icons.battery_full;
    } else if (level > 50) {
      color = Colors.green;
      icon = Icons.battery_5_bar;
    } else if (level > 20) {
      color = Colors.orange;
      icon = Icons.battery_3_bar;
    } else {
      color = Colors.red;
      icon = Icons.battery_1_bar;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          '$level%',
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }
}
