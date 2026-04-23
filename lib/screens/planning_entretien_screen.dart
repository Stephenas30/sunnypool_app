import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'profile_screen.dart';

class PlanningEntretienScreen extends StatefulWidget {
  const PlanningEntretienScreen({super.key});

  @override
  State<PlanningEntretienScreen> createState() =>
      _PlanningEntretienScreenState();
}

enum ButtonOption { calendar, list }

class _PlanningTask {
  _PlanningTask({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.notes = '',
    this.isDone = false,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final String notes;
  final bool isDone;

  _PlanningTask copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    String? notes,
    bool? isDone,
  }) {
    return _PlanningTask(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      isDone: isDone ?? this.isDone,
    );
  }
}

class _PlanningDataSource extends CalendarDataSource {
  _PlanningDataSource(List<Appointment> source) {
    appointments = source;
  }

  void updateAppointments(List<Appointment> source) {
    appointments = source;
    notifyListeners(CalendarDataSourceAction.reset, source);
  }
}

class _PlanningDraft {
  _PlanningDraft({
    required this.title,
    required this.notes,
    required this.startTime,
    required this.endTime,
    required this.color,
  });

  final String title;
  final String notes;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
}

class _AddPlanningBottomSheet extends StatefulWidget {
  const _AddPlanningBottomSheet();

  @override
  State<_AddPlanningBottomSheet> createState() =>
      _AddPlanningBottomSheetState();
}

class _AddPlanningBottomSheetState extends State<_AddPlanningBottomSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DateFormat _fullDateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _durationInMinutes;
  late Color _selectedColor;

  bool _isDatePickerOpen = false;
  bool _isTimePickerOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _durationInMinutes = 60;
    _selectedColor = Colors.amber.shade700;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (_isDatePickerOpen) {
      return;
    }
    _isDatePickerOpen = true;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('fr', 'FR'),
    );
    _isDatePickerOpen = false;
    if (!mounted || picked == null) {
      return;
    }
    setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    if (_isTimePickerOpen) {
      return;
    }
    _isTimePickerOpen = true;
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    _isTimePickerOpen = false;
    if (!mounted || picked == null) {
      return;
    }
    setState(() => _selectedTime = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final startTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final endTime = startTime.add(Duration(minutes: _durationInMinutes));

    Navigator.of(context).pop(
      _PlanningDraft(
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        startTime: startTime,
        endTime: endTime,
        color: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ajouter un planning',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Titre de la tâche',
                    hintText: 'Ex: Nettoyage du filtre',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le titre est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.event),
                        label: Text(_fullDateFormat.format(_selectedDate)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.schedule),
                        label: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _durationInMinutes,
                  decoration: const InputDecoration(labelText: 'Durée'),
                  items: const [
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                    DropdownMenuItem(value: 45, child: Text('45 minutes')),
                    DropdownMenuItem(value: 60, child: Text('1 heure')),
                    DropdownMenuItem(value: 90, child: Text('1 heure 30')),
                    DropdownMenuItem(value: 120, child: Text('2 heures')),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _durationInMinutes = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Color>(
                  initialValue: _selectedColor,
                  decoration: const InputDecoration(
                    labelText: 'Type / Couleur',
                  ),
                  items: [
                    DropdownMenuItem(
                      value: Colors.amber.shade700,
                      child: const Text('Nettoyage'),
                    ),
                    DropdownMenuItem(
                      value: Colors.lightBlue.shade600,
                      child: const Text('Analyse de l\'eau'),
                    ),
                    DropdownMenuItem(
                      value: Colors.green.shade600,
                      child: const Text('Vérification équipement'),
                    ),
                    DropdownMenuItem(
                      value: Colors.deepOrange.shade400,
                      child: const Text('Traitement'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _selectedColor = value);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter au planning'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanningEntretienScreenState extends State<PlanningEntretienScreen> {
  final List<_PlanningTask> _planningItems = [];
  final DateFormat _dayFormat = DateFormat('EEEE d MMMM', 'fr_FR');
  final DateFormat _hourFormat = DateFormat('HH:mm', 'fr_FR');
  late final _PlanningDataSource _planningDataSource;

  ButtonOption _buttonOption = ButtonOption.calendar;
  bool _isAddSheetOpen = false;
  int _taskSequence = 3;

  @override
  void initState() {
    super.initState();
    _seedPlanning();
    _planningDataSource = _PlanningDataSource(_appointmentsFromPlanning());
  }

  void _seedPlanning() {
    final now = DateTime.now();
    _planningItems.addAll([
      _PlanningTask(
        id: 'task_1',
        title: 'Nettoyer les skimmers',
        startTime: DateTime(now.year, now.month, now.day + 1, 8, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 8, 45),
        color: Colors.amber.shade700,
        notes: 'Retirer les feuilles et vérifier le panier.',
      ),
      _PlanningTask(
        id: 'task_2',
        title: 'Tester l\'eau (pH/chlore)',
        startTime: DateTime(now.year, now.month, now.day + 2, 9, 0),
        endTime: DateTime(now.year, now.month, now.day + 2, 9, 30),
        color: Colors.lightBlue.shade600,
      ),
      _PlanningTask(
        id: 'task_3',
        title: 'Inspection de la pompe',
        startTime: DateTime(now.year, now.month, now.day + 3, 10, 15),
        endTime: DateTime(now.year, now.month, now.day + 3, 11, 0),
        color: Colors.green.shade600,
      ),
    ]);
    _sortPlanning();
  }

  void _sortPlanning() {
    _planningItems.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Appointment> _appointmentsFromPlanning() {
    return _planningItems
        .map(
          (item) => Appointment(
            id: item.id,
            startTime: item.startTime,
            endTime: item.endTime,
            subject: item.title,
            notes: item.notes,
            color: item.isDone ? Colors.grey : item.color,
          ),
        )
        .toList();
  }

  void _syncCalendarSource() {
    _planningDataSource.updateAppointments(_appointmentsFromPlanning());
  }

  String _nextTaskId() {
    _taskSequence += 1;
    return 'task_${DateTime.now().microsecondsSinceEpoch}_$_taskSequence';
  }

  Future<void> _showAddPlanningSheet() async {
    if (_isAddSheetOpen) {
      return;
    }
    _isAddSheetOpen = true;
    try {
      final draft = await showModalBottomSheet<_PlanningDraft>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF121212),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const _AddPlanningBottomSheet(),
      );

      if (!mounted || draft == null) {
        return;
      }

      setState(() {
        _planningItems.add(
          _PlanningTask(
            id: _nextTaskId(),
            title: draft.title,
            notes: draft.notes,
            startTime: draft.startTime,
            endTime: draft.endTime,
            color: draft.color,
          ),
        );
        _sortPlanning();
        _syncCalendarSource();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Planning ajouté avec succès')),
      );
    } finally {
      _isAddSheetOpen = false;
    }
  }

  void _toggleDone(String id) {
    final index = _planningItems.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    setState(() {
      final item = _planningItems[index];
      _planningItems[index] = item.copyWith(isDone: !item.isDone);
      _syncCalendarSource();
    });
  }

  void _removePlanning(String id) {
    setState(() {
      _planningItems.removeWhere((item) => item.id == id);
      _syncCalendarSource();
    });
  }

  Future<void> _showPlanningActions(_PlanningTask item) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF171717),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                ListTile(
                  title: Text(
                    item.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${_dayFormat.format(item.startTime)} • ${_hourFormat.format(item.startTime)} - ${_hourFormat.format(item.endTime)}',
                  ),
                ),
                ListTile(
                  leading: Icon(
                    item.isDone
                        ? Icons.radio_button_unchecked
                        : Icons.check_circle_outline,
                    color: Colors.amber,
                  ),
                  title: Text(
                    item.isDone ? 'Marquer non terminé' : 'Marquer terminé',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleDone(item.id);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _removePlanning(item.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onCalendarTap(CalendarTapDetails details) {
    if (details.targetElement != CalendarElement.appointment ||
        details.appointments == null ||
        details.appointments!.isEmpty) {
      return;
    }
    final appointment = details.appointments!.first as Appointment;
    final id = appointment.id as String?;
    if (id == null) {
      return;
    }
    final selectedItem = _planningItems
        .where((item) => item.id == id)
        .firstOrNull;
    if (selectedItem == null) {
      return;
    }
    _showPlanningActions(selectedItem);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning d\'entretien'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/icon.png'),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050505), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Organise les entretiens de ta piscine',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<ButtonOption>(
              segments: const [
                ButtonSegment<ButtonOption>(
                  value: ButtonOption.calendar,
                  icon: Icon(Icons.calendar_month_outlined),
                  label: Text('Calendrier'),
                ),
                ButtonSegment<ButtonOption>(
                  value: ButtonOption.list,
                  icon: Icon(Icons.list_alt_outlined),
                  label: Text('Liste'),
                ),
              ],
              selected: {_buttonOption},
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                selectedBackgroundColor: Colors.amber.shade700,
                selectedForegroundColor: Colors.white,
              ),
              onSelectionChanged: (selection) {
                setState(() => _buttonOption = selection.first);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buttonOption == ButtonOption.calendar
                  ? _buildCalendarPlanning()
                  : _buildListPlanning(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showAddPlanningSheet,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un planning'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarPlanning() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SfCalendar(
        view: CalendarView.month,
        firstDayOfWeek: 1,
        // Workaround: avoid SfCalendar internal date-picker route lifecycle
        // issues that can trigger duplicate key/element assertions.
        showDatePickerButton: false,
        showNavigationArrow: true,
        monthViewSettings: const MonthViewSettings(
          // Better stability with multiple events on the same day.
          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
          showAgenda: true,
          agendaViewHeight: 180,
        ),
        todayHighlightColor: Colors.amber,
        dataSource: _planningDataSource,
        onTap: _onCalendarTap,
      ),
    );
  }

  Widget _buildListPlanning() {
    if (_planningItems.isEmpty) {
      return Center(
        child: Text(
          'Aucun planning pour le moment',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      itemCount: _planningItems.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _planningItems[index];
        return Card(
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: ListTile(
            onTap: () => _showPlanningActions(item),
            leading: Icon(
              item.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: item.isDone ? Colors.greenAccent : item.color,
            ),
            title: Text(
              item.title,
              style: TextStyle(
                color: Colors.white,
                decoration: item.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              '${_dayFormat.format(item.startTime)} • ${_hourFormat.format(item.startTime)} - ${_hourFormat.format(item.endTime)}'
              '${item.notes.isEmpty ? '' : '\n${item.notes}'}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onPressed: () => _showPlanningActions(item),
            ),
            isThreeLine: item.notes.isNotEmpty,
          ),
        );
      },
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
