import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A real Firestore-backed vehicle list using the existing vehicles contract.
class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  bool _isAdding = false;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _addVehicle() async {
    final uid = _uid;
    if (uid == null || _isAdding) return;

    final formKey = GlobalKey<FormState>();
    final make = TextEditingController();
    final model = TextEditingController();
    final year = TextEditingController();
    final colour = TextEditingController();
    final plate = TextEditingController();
    var type = 'Car';
    var fuelType = 'Petrol';

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(height: 20),
                  Text('Add a vehicle', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  _VehicleField(controller: make, label: 'Make', hint: 'Toyota'),
                  const SizedBox(height: 12),
                  _VehicleField(controller: model, label: 'Model', hint: 'Corolla'),
                  const SizedBox(height: 12),
                  _VehicleField(controller: year, label: 'Year', hint: '2020', keyboardType: TextInputType.number, validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Enter the vehicle year';
                    final parsed = int.tryParse(value.trim());
                    if (parsed == null || parsed < 1950 || parsed > DateTime.now().year + 1) return 'Enter a valid year';
                    return null;
                  }),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Vehicle type'),
                    items: const ['Car', 'SUV', 'Van', 'Truck', 'Motorcycle', 'Other'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setSheetState(() => type = v ?? 'Car'),
                  ),
                  const SizedBox(height: 12),
                  _VehicleField(controller: colour, label: 'Colour', hint: 'Silver'),
                  const SizedBox(height: 12),
                  _VehicleField(controller: plate, label: 'Plate number (optional)', hint: 'ABC-123XY', requiredField: false),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: fuelType,
                    decoration: const InputDecoration(labelText: 'Fuel type'),
                    items: const ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'LPG', 'Other'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setSheetState(() => fuelType = v ?? 'Petrol'),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.of(sheetContext).pop(true);
                    },
                    child: const Text('Save vehicle'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (submitted != true || !mounted) return;
    setState(() => _isAdding = true);
    try {
      await FirebaseFirestore.instance.collection('vehicles').add({
        'ownerId': uid,
        'make': make.text.trim(),
        'model': model.text.trim(),
        'year': year.text.trim(),
        'type': type,
        'colour': colour.text.trim(),
        'plateNumber': plate.text.trim(),
        'fuelType': fuelType,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle added successfully.')));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.code == 'permission-denied' ? 'You do not have permission to save this vehicle.' : 'Could not save the vehicle. Please try again.')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save the vehicle. Please try again.')));
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }

    make.dispose();
    model.dispose();
    year.dispose();
    colour.dispose();
    plate.dispose();
  }

  Future<void> _showVehicleDetails(Map<String, dynamic> vehicle) async {
    final name = '${vehicle['year'] ?? ''} ${vehicle['make'] ?? ''} ${vehicle['model'] ?? ''}'.trim();
    final rows = <(String, String)>[
      ('Make', vehicle['make']?.toString() ?? 'Not provided'),
      ('Model', vehicle['model']?.toString() ?? 'Not provided'),
      ('Year', vehicle['year']?.toString() ?? 'Not provided'),
      ('Type', vehicle['type']?.toString() ?? 'Not provided'),
      ('Colour', vehicle['colour']?.toString() ?? 'Not provided'),
      ('Fuel', vehicle['fuelType']?.toString() ?? 'Not provided'),
      ('Plate number', (vehicle['plateNumber'] as String?)?.trim().isNotEmpty == true
          ? vehicle['plateNumber'] as String
          : 'Not provided'),
    ];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(name.isEmpty ? 'Vehicle details' : name),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rows.map((row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 110, child: Text(row.$1, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                  Expanded(child: Text(row.$2, style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _editVehicle(
    String vehicleId,
    Map<String, dynamic> vehicle,
  ) async {
    final make = TextEditingController(text: vehicle['make'] as String? ?? '');
    final model = TextEditingController(text: vehicle['model'] as String? ?? '');
    final year = TextEditingController(text: vehicle['year']?.toString() ?? '');
    final colour = TextEditingController(text: vehicle['colour'] as String? ?? '');
    final plate = TextEditingController(text: vehicle['plateNumber'] as String? ?? '');
    final formKey = GlobalKey<FormState>();
    var type = vehicle['type'] as String? ?? 'Car';
    var fuelType = vehicle['fuelType'] as String? ?? 'Petrol';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit vehicle'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _VehicleField(controller: make, label: 'Make', hint: 'Toyota'),
                    const SizedBox(height: 10),
                    _VehicleField(controller: model, label: 'Model', hint: 'Corolla'),
                    const SizedBox(height: 10),
                    _VehicleField(
                      controller: year,
                      label: 'Year',
                      hint: '2020',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = int.tryParse(value?.trim() ?? '');
                        if (parsed == null || parsed < 1950 || parsed > DateTime.now().year + 1) {
                          return 'Enter a valid year';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: ['Car', 'SUV', 'Van', 'Truck', 'Motorcycle', 'Other'].contains(type) ? type : 'Other',
                      decoration: const InputDecoration(labelText: 'Vehicle type'),
                      items: const ['Car', 'SUV', 'Van', 'Truck', 'Motorcycle', 'Other'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (value) => setDialogState(() => type = value ?? type),
                    ),
                    const SizedBox(height: 10),
                    _VehicleField(controller: colour, label: 'Colour', hint: 'Silver'),
                    const SizedBox(height: 10),
                    _VehicleField(controller: plate, label: 'Plate number (optional)', hint: 'ABC-123XY', requiredField: false),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'LPG', 'Other'].contains(fuelType) ? fuelType : 'Other',
                      decoration: const InputDecoration(labelText: 'Fuel type'),
                      items: const ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'LPG', 'Other'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (value) => setDialogState(() => fuelType = value ?? fuelType),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true);
              },
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      try {
        await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).update({
          'make': make.text.trim(),
          'model': model.text.trim(),
          'year': year.text.trim(),
          'type': type,
          'colour': colour.text.trim(),
          'plateNumber': plate.text.trim(),
          'fuelType': fuelType,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle updated.')));
        }
      } on FirebaseException catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.code == 'permission-denied'
                ? 'You do not have permission to edit this vehicle.'
                : 'Could not update the vehicle. Please try again.'),
          ));
        }
      }
    }
    make.dispose();
    model.dispose();
    year.dispose();
    colour.dispose();
    plate.dispose();
  }

  Future<void> _deleteVehicle(String vehicleId, String vehicleName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this vehicle?'),
        content: Text('Remove $vehicleName from your garage? Existing repair records may still refer to it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep vehicle')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle removed.')));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.code == 'permission-denied'
              ? 'You do not have permission to remove this vehicle.'
              : 'Could not remove the vehicle. Please try again.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Sign in to manage your vehicles.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My vehicles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isAdding ? null : _addVehicle,
        icon: _isAdding ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_rounded),
        label: const Text('Add vehicle'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('vehicles').where('ownerId', isEqualTo: uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _VehicleMessage(icon: Icons.cloud_off_outlined, title: 'Could not load vehicles', message: 'Check your connection and try again.');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 112),
              children: const [
                _VehicleMessage(icon: Icons.directions_car_outlined, title: 'No vehicles yet', message: 'Add your car or motorcycle so repair requests can be linked to the right vehicle.'),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final name = '${data['year'] ?? ''} ${data['make'] ?? ''} ${data['model'] ?? ''}'.trim();
              final detail = [data['type'], data['colour'], data['fuelType']]
                  .whereType<String>()
                  .where((value) => value.trim().isNotEmpty)
                  .join(' • ');
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
                  leading: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(15)),
                    child: Icon(Icons.directions_car_filled_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 28),
                  ),
                  title: Text(name.isEmpty ? 'Vehicle' : name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text([detail, data['plateNumber'] as String? ?? ''].where((v) => v.trim().isNotEmpty).join('\n')),
                  isThreeLine: detail.isNotEmpty && (data['plateNumber'] as String? ?? '').isNotEmpty,
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Vehicle actions',
                    onSelected: (action) {
                      if (action == 'details') {
                        _showVehicleDetails(data);
                      } else if (action == 'edit') {
                        _editVehicle(docs[index].id, data);
                      } else if (action == 'delete') {
                        _deleteVehicle(docs[index].id, name.isEmpty ? 'this vehicle' : name);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'details', child: ListTile(leading: Icon(Icons.info_outline_rounded), title: Text('View details'), contentPadding: EdgeInsets.zero, dense: true)),
                      PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'), contentPadding: EdgeInsets.zero, dense: true)),
                      PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline_rounded), title: Text('Remove'), contentPadding: EdgeInsets.zero, dense: true)),
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

class _VehicleField extends StatelessWidget {
  const _VehicleField({required this.controller, required this.label, required this.hint, this.keyboardType, this.requiredField = true, this.validator});
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool requiredField;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    textCapitalization: TextCapitalization.words,
    decoration: InputDecoration(labelText: label, hintText: hint),
    validator: validator ?? (value) {
      if (requiredField && (value == null || value.trim().isEmpty)) return 'Enter $label'.toLowerCase();
      return null;
    },
  );
}

class _VehicleMessage extends StatelessWidget {
  const _VehicleMessage({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 54, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 18),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    ),
  );
}
