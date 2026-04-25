import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  List<String> _allergies = [];
  List<String> _conditions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _allergies = List.from(user?.allergies ?? []);
    _conditions = List.from(user?.conditions ?? []);
  }

  Future<void> _addAllergy() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _AddItemDialog(title: 'Add Allergy'),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _allergies.add(result));
      _saveChanges();
    }
  }

  Future<void> _addCondition() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _AddItemDialog(title: 'Add Medical Condition'),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _conditions.add(result));
      _saveChanges();
    }
  }

  void _removeAllergy(int index) {
    setState(() => _allergies.removeAt(index));
    _saveChanges();
  }

  void _removeCondition(int index) {
    setState(() => _conditions.removeAt(index));
    _saveChanges();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    final currentUser = context.read<AuthProvider>().user;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        allergies: _allergies,
        conditions: _conditions,
      );
      context.read<AuthProvider>().updateUser(updatedUser);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Basic Health Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryDark, AppTheme.primaryLight],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Health Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _HealthInfoItem(
                      icon: Icons.bloodtype_rounded,
                      label: 'Blood Group',
                      value: user?.bloodGroup ?? 'N/A',
                    ),
                    _HealthInfoItem(
                      icon: Icons.cake_rounded,
                      label: 'Age',
                      value: user?.age != null ? '${user!.age} yrs' : 'N/A',
                    ),
                    _HealthInfoItem(
                      icon: Icons.wc_rounded,
                      label: 'Gender',
                      value: user?.gender ?? 'N/A',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Allergies Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Allergies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                onPressed: _addAllergy,
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_allergies.isEmpty)
            _EmptyState(
              icon: Icons.warning_amber_rounded,
              message: 'No allergies recorded',
              color: AppTheme.warningColor,
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allergies.asMap().entries.map((entry) {
                  return _MedicalChip(
                    label: entry.value,
                    color: AppTheme.warningColor,
                    onDelete: () => _removeAllergy(entry.key),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 24),

          // Medical Conditions Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medical Conditions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                onPressed: _addCondition,
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_conditions.isEmpty)
            _EmptyState(
              icon: Icons.monitor_heart_rounded,
              message: 'No medical conditions recorded',
              color: AppTheme.errorColor,
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _conditions.asMap().entries.map((entry) {
                  return _MedicalChip(
                    label: entry.value,
                    color: AppTheme.errorColor,
                    onDelete: () => _removeCondition(entry.key),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 24),

          // Medical History (Placeholder)
          const Text(
            'Recent Medical History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          _MedicalHistoryCard(
            date: DateTime.now().subtract(const Duration(days: 15)),
            title: 'General Checkup',
            doctor: 'Dr. Rajesh Kumar',
            notes: 'Routine health examination. All vitals normal.',
          ),
          const SizedBox(height: 10),
          
          _MedicalHistoryCard(
            date: DateTime.now().subtract(const Duration(days: 45)),
            title: 'Blood Test',
            doctor: 'Dr. Priya Sharma',
            notes: 'Complete blood count. Results within normal range.',
          ),
          const SizedBox(height: 10),
          
          _MedicalHistoryCard(
            date: DateTime.now().subtract(const Duration(days: 90)),
            title: 'Dental Checkup',
            doctor: 'Dr. Amit Patel',
            notes: 'Dental cleaning and examination completed.',
          ),
        ],
      ),
    );
  }
}

class _HealthInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HealthInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MedicalChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onDelete;

  const _MedicalChip({
    required this.label,
    required this.color,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      backgroundColor: color.withOpacity(0.1),
      deleteIcon: Icon(Icons.close_rounded, size: 18, color: color),
      onDeleted: onDelete,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalHistoryCard extends StatelessWidget {
  final DateTime date;
  final String title;
  final String doctor;
  final String notes;

  const _MedicalHistoryCard({
    required this.date,
    required this.title,
    required this.doctor,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            doctor,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            notes,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final String title;

  const _AddItemDialog({required this.title});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Enter details',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
