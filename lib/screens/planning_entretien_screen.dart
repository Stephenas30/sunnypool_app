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
}

class _PlanningEntretienScreenState extends State<PlanningEntretienScreen> {
  final List<_PlanningTask> _planningItems = [];
  final DateFormat _dayFormat = DateFormat('EEEE d MMMM', 'fr_FR');
  final DateFormat _hourFormat = DateFormat('HH:mm', 'fr_FR');
  final DateFormat _fullDateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

  ButtonOption _buttonOption = ButtonOption.calendar;

  @override
  void initState() {
    super.initState();
    _seedPlanning();
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

  CalendarDataSource _calendarSource() {
    final appointments = _planningItems
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
    return _PlanningDataSource(appointments);
  }

  Future<void> _showAddPlanningSheet() async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    int durationInMinutes = 60;
    Color selectedColor = Colors.amber.shade700;

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
                child: Form(
                  key: formKey,
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
                          controller: titleController,
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
                          controller: notesController,
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
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 365),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365 * 2),
                                    ),
                                    locale: const Locale('fr', 'FR'),
                                  );
                                  if (picked != null) {
                                    setModalState(() => selectedDate = picked);
                                  }
                                },
                                icon: const Icon(Icons.event),
                                label: Text(
                                  _fullDateFormat.format(selectedDate),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );
                                  if (picked != null) {
                                    setModalState(() => selectedTime = picked);
                                  }
                                },
                                icon: const Icon(Icons.schedule),
                                label: Text(selectedTime.format(context)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: durationInMinutes,
                          decoration: const InputDecoration(labelText: 'Durée'),
                          items: const [
                            DropdownMenuItem(
                              value: 30,
                              child: Text('30 minutes'),
                            ),
                            DropdownMenuItem(
                              value: 45,
                              child: Text('45 minutes'),
                            ),
                            DropdownMenuItem(value: 60, child: Text('1 heure')),
                            DropdownMenuItem(
                              value: 90,
                              child: Text('1 heure 30'),
                            ),
                            DropdownMenuItem(
                              value: 120,
                              child: Text('2 heures'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => durationInMinutes = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Color>(
                          initialValue: selectedColor,
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
                            if (value != null) {
                              setModalState(() => selectedColor = value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }
                            final startTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                            final endTime = startTime.add(
                              Duration(minutes: durationInMinutes),
                            );

                            setState(() {
                              _planningItems.add(
                                _PlanningTask(
                                  id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                                  title: titleController.text.trim(),
                                  notes: notesController.text.trim(),
                                  startTime: startTime,
                                  endTime: endTime,
                                  color: selectedColor,
                                ),
                              );
                              _sortPlanning();
                            });

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Planning ajouté avec succès'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter au planning'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    notesController.dispose();
  }

  void _toggleDone(String id) {
    final index = _planningItems.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    setState(() {
      final item = _planningItems[index];
      _planningItems[index] = item.copyWith(isDone: !item.isDone);
    });
  }

  void _removePlanning(String id) {
    setState(() {
      _planningItems.removeWhere((item) => item.id == id);
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
        showDatePickerButton: true,
        showNavigationArrow: true,
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          showAgenda: true,
          agendaViewHeight: 180,
        ),
        todayHighlightColor: Colors.amber,
        dataSource: _calendarSource(),
        onTap: _onCalendarTap,
        appointmentBuilder: (context, details) {
          final appointment = details.appointments.first as Appointment;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: appointment.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              appointment.subject,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
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
