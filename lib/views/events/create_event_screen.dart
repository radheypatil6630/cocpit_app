import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/event_model.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();

  String selectedCategory = 'Tech';
  String selectedEventType = 'Online';

  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;

  bool isFreeEvent = true;

  File? bannerImage; // 🔥 USER SELECTED IMAGE

  final categories = [
    'Tech',
    'Business',
    'Networking',
    'Workshop',
    'Conference',
    'Summit',
  ];

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Create Event', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bannerPicker(theme),

                _section(theme, 'Basic Info'),
                _card(theme, [
                  _field(theme, 'Event Title', titleCtrl),
                  _field(theme, 'Description', descCtrl, maxLines: 3),
                  _field(theme, 'Location', locationCtrl),
                ]),

                _section(theme, 'Category'),
                _card(theme, [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories
                        .map((c) => _chip(
                      theme,
                      c,
                      selectedCategory == c,
                          () => setState(() => selectedCategory = c),
                    ))
                        .toList(),
                  ),
                ]),

                _section(theme, 'Event Type'),
                _card(theme, [
                  Row(
                    children: [
                      _chip(
                        theme,
                        'Online',
                        selectedEventType == 'Online',
                            () => setState(() => selectedEventType = 'Online'),
                      ),
                      const SizedBox(width: 12),
                      _chip(
                        theme,
                        'In-person',
                        selectedEventType == 'In-person',
                            () => setState(() => selectedEventType = 'In-person'),
                      ),
                    ],
                  ),
                ]),

                _section(theme, 'Date & Time'),
                _card(theme, [
                  _dateTimeRow(
                    theme,
                    'Start',
                    startDate,
                    startTime,
                    onDateTap: () async {
                      final d = await _pickDate();
                      if (d != null) setState(() => startDate = d);
                    },
                    onTimeTap: () async {
                      final t = await _pickTime();
                      if (t != null) setState(() => startTime = t);
                    },
                  ),
                  const SizedBox(height: 12),
                  _dateTimeRow(
                    theme,
                    'End',
                    endDate,
                    endTime,
                    onDateTap: () async {
                      final d = await _pickDate();
                      if (d != null) setState(() => endDate = d);
                    },
                    onTimeTap: () async {
                      final t = await _pickTime();
                      if (t != null) setState(() => endTime = t);
                    },
                  ),
                ]),

                _section(theme, 'Pricing'),
                _card(theme, [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isFreeEvent,
                    onChanged: (v) => setState(() => isFreeEvent = v),
                    title: Text(
                      'Free Event',
                      style: theme.textTheme.bodyLarge,
                    ),
                    activeColor: theme.primaryColor,
                  ),
                ]),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _createEvent,
                    child: const Text(
                      'Create Event',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= BANNER PICKER =================

  Widget _bannerPicker(ThemeData theme) {
    return GestureDetector(
      onTap: _pickBanner,
      child: Container(
        height: 190,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          image: DecorationImage(
            image: bannerImage != null
                ? FileImage(bannerImage!)
                : const AssetImage('lib/images/event_placeholder.jpg')
            as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
          ),
          child: const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Add Event Banner',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final XFile? file =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

    if (file != null) {
      setState(() => bannerImage = File(file.path));
    }
  }

  // ================= HELPERS =================

  Widget _section(ThemeData theme, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 16),
    child: Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _card(ThemeData theme, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: theme.dividerColor),
    ),
    child: Column(children: children),
  );

  Widget _field(ThemeData theme, String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
        ),
      ),
    );
  }

  Widget _chip(ThemeData theme, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.primaryColor : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(30),
          border: selected ? null : Border.all(color: theme.dividerColor),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : theme.textTheme.bodyMedium?.color)),
      ),
    );
  }

  Widget _dateTimeRow(
      ThemeData theme,
      String label,
      DateTime? date,
      TimeOfDay? time, {
        required VoidCallback onDateTap,
        required VoidCallback onTimeTap,
      }) {
    return Row(
      children: [
        Expanded(
          child: _dateTimeBox(
            theme,
            date == null
                ? '$label Date'
                : '${date.day}/${date.month}/${date.year}',
            Icons.calendar_today,
            onDateTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _dateTimeBox(
            theme,
            time == null ? 'Time' : time.format(context),
            Icons.access_time,
            onTimeTap,
          ),
        ),
      ],
    );
  }

  Widget _dateTimeBox(
      ThemeData theme,
      String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), size: 18),
            const SizedBox(width: 10),
            Text(value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate() {
    return showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );
  }

  Future<TimeOfDay?> _pickTime() {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  // ================= CREATE EVENT =================

  void _createEvent() {
    if (!_formKey.currentState!.validate()) return;
    if (startDate == null ||
        startTime == null ||
        endDate == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date & time')),
      );
      return;
    }

    final event = EventModel(
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      location: locationCtrl.text.trim(),
      category: selectedCategory,
      eventType: selectedEventType,
      startDate:
      '${startDate!.day}/${startDate!.month}/${startDate!.year}',
      startTime: startTime!.format(context),
      endDate: '${endDate!.day}/${endDate!.month}/${endDate!.year}',
      endTime: endTime!.format(context),
      image: bannerImage?.path ?? 'lib/images/event_placeholder.jpg',
      isFree: isFreeEvent,
    );

    Navigator.pop(context, event);
  }
}
