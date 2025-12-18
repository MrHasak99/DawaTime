import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawatime/utils/medication_helpers.dart';
import 'package:flutter/material.dart';
import 'package:dawatime/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dawatime/login_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dawatime/l10n/app_localizations.dart';
import 'package:dawatime/utils/medication_notifications.dart';
import 'package:dawatime/utils/string_utils.dart';

enum FrequencyType { everyXDays, daysOfWeek }

class AddMedications extends StatefulWidget {
  final String uid;
  final Medications? medication;
  final String? docId;

  const AddMedications({
    super.key,
    required this.uid,
    this.medication,
    this.docId,
  });

  @override
  State<AddMedications> createState() => _AddMedicationsState();
}

class _AddMedicationsState extends State<AddMedications> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController typeOfMedicationController = TextEditingController();
  TextEditingController dosageController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController frequencyController = TextEditingController();
  TextEditingController refillThresholdController = TextEditingController();
  TimeOfDay? _selectedTime;
  DateTime? _selectedStartDate;
  List<int> _selectedDaysOfWeek = [];
  FrequencyType _frequencyType = FrequencyType.everyXDays;
  bool _nameError = false;
  bool _typeError = false;
  bool _dosageError = false;
  bool _amountError = false;
  bool _frequencyError = false;
  bool _timeError = false;
  bool _startDateError = false;
  bool _daysOfWeekError = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      nameController.text = widget.medication!.name;
      typeOfMedicationController.text = widget.medication!.typeOfMedication;
      dosageController.text = widget.medication!.dosage.toString();
      frequencyController.text = widget.medication!.frequency.toString();
      amountController.text = widget.medication!.amount.toString();
      if (widget.medication!.refillThreshold != null) {
        refillThresholdController.text =
            widget.medication!.refillThreshold!.toString();
      }
      if (widget.medication!.notifyTime != null &&
          widget.medication!.notifyTime!.isNotEmpty) {
        final parts = widget.medication!.notifyTime!.split(':');
        if (parts.length == 2) {
          _selectedTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
      if (widget.medication!.startDate != null) {
        _selectedStartDate = widget.medication!.startDate;
      }
      if (widget.medication!.daysOfWeek != null &&
          widget.medication!.daysOfWeek!.isNotEmpty) {
        if (widget.medication!.daysOfWeek is String) {
          final days = (widget.medication!.daysOfWeek as String).split(',');
          _selectedDaysOfWeek =
              days
                  .map((day) => int.tryParse(day.trim()) ?? 0)
                  .where((day) => day > 0 && day < 8)
                  .toList();
        } else if (widget.medication!.daysOfWeek is List) {
          _selectedDaysOfWeek =
              List<int>.from(
                widget.medication!.daysOfWeek!,
              ).where((day) => day > 0 && day < 8).toList();
        }
      }
    }
    selectNotificationStream.stream.listen((
      NotificationResponse response,
    ) async {
      if (response.payload != null && context.mounted) {
        final payload = response.payload!;

        if (payload == 'refill_multiple' || payload.startsWith('refill_')) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc =
              await FirebaseFirestore.instance
                  .collection(user.uid)
                  .doc(payload)
                  .get();
          if (doc.exists) {
            final medication = medicationFromDoc(doc);
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: const Color(0xFF8AC249),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!.timeToTakeMedication(medication.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          AppLocalizations.of(context)!.ok,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF8AC249)),
        ),
      );
    }

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection(user.uid).limit(12).get(),
      builder: (context, snapshot) {
        final medicationCount = snapshot.data?.docs.length ?? 0;
        final isAtLimit = medicationCount >= 12;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF8AC249),
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: BackButton(color: Colors.white),
                  title: Text(AppLocalizations.of(context)!.addNewMedication),
                  centerTitle: true,
                ),
              ),
            ),
            body:
                isAtLimit
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning,
                              color: Colors.red,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.youCanOnlyHaveUpTo12Medications,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                    : LayoutBuilder(
                      builder: (context, constraints) {
                        return SafeArea(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom + 24,
                              top: 24,
                              left: 24,
                              right: 24,
                            ),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 500),
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF8AC249,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFF8AC249,
                                              ).withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: const Color(0xFF8AC249),
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.notificationContinuityWarning,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(fontSize: 11),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: nameController,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          cursorColor: Color(0xFF8AC249),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          onChanged: (value) {
                                            if (_nameError &&
                                                value.isNotEmpty) {
                                              setState(
                                                () => _nameError = false,
                                              );
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(
                                                  context,
                                                )!.name,
                                            labelStyle: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              color:
                                                  _nameError
                                                      ? Colors.red
                                                      : (Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            errorText:
                                                _nameError
                                                    ? AppLocalizations.of(
                                                      context,
                                                    )!.pleaseFillAllFields
                                                    : null,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller:
                                              typeOfMedicationController,
                                          cursorColor: Color(0xFF8AC249),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          onChanged: (value) {
                                            if (_typeError &&
                                                value.isNotEmpty) {
                                              setState(
                                                () => _typeError = false,
                                              );
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(
                                                  context,
                                                )!.unitOfMeasurement,
                                            labelStyle: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              color:
                                                  _typeError
                                                      ? Colors.red
                                                      : (Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            errorText:
                                                _typeError
                                                    ? AppLocalizations.of(
                                                      context,
                                                    )!.pleaseFillAllFields
                                                    : null,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: dosageController,
                                          cursorColor: Color(0xFF8AC249),
                                          keyboardType: TextInputType.number,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          onChanged: (value) {
                                            if (_dosageError &&
                                                value.isNotEmpty &&
                                                convertArabicNumerals(value) !=
                                                    '0') {
                                              setState(
                                                () => _dosageError = false,
                                              );
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(
                                                  context,
                                                )!.dosage,
                                            labelStyle: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              color:
                                                  _dosageError
                                                      ? Colors.red
                                                      : (Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            errorText:
                                                _dosageError
                                                    ? AppLocalizations.of(
                                                      context,
                                                    )!.dosageFrequencyGreaterThanZero
                                                    : null,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: amountController,
                                          cursorColor: Color(0xFF8AC249),
                                          keyboardType: TextInputType.number,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          onChanged: (value) {
                                            if (_amountError &&
                                                value.isNotEmpty) {
                                              setState(
                                                () => _amountError = false,
                                              );
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(
                                                  context,
                                                )!.currentAmount,
                                            labelStyle: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              color:
                                                  _amountError
                                                      ? Colors.red
                                                      : (Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            errorText:
                                                _amountError
                                                    ? AppLocalizations.of(
                                                      context,
                                                    )!.pleaseFillAllFields
                                                    : null,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: refillThresholdController,
                                          cursorColor: Color(0xFF8AC249),
                                          keyboardType: TextInputType.number,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(
                                                  context,
                                                )!.refillThreshold,
                                            labelStyle: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              color:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ListTile(
                                          title: Text(
                                            _selectedTime == null
                                                ? AppLocalizations.of(
                                                  context,
                                                )!.pickNotificationTime
                                                : "${AppLocalizations.of(context)!.notifyAt}: ${_selectedTime!.format(context)}",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  _timeError
                                                      ? Colors.red
                                                      : null,
                                            ),
                                          ),
                                          trailing: Icon(
                                            Icons.access_time,
                                            color:
                                                _timeError ? Colors.red : null,
                                          ),
                                          onTap: () async {
                                            final isDark =
                                                Theme.of(context).brightness ==
                                                Brightness.dark;
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime:
                                                  _selectedTime ??
                                                  TimeOfDay.now(),
                                              builder: (context, child) {
                                                final primaryColor =
                                                    const Color(0xFF8AC249);
                                                final surfaceColor =
                                                    isDark
                                                        ? const Color(
                                                          0xFF222222,
                                                        )
                                                        : Colors.white;
                                                final onSurfaceColor =
                                                    isDark
                                                        ? Colors.white
                                                        : primaryColor;
                                                final hourMinuteBg =
                                                    isDark
                                                        ? primaryColor
                                                            .withValues(
                                                              alpha: 0.15,
                                                            )
                                                        : primaryColor
                                                            .withValues(
                                                              alpha: 0.08,
                                                            );

                                                return Theme(
                                                  data: Theme.of(
                                                    context,
                                                  ).copyWith(
                                                    timePickerTheme: TimePickerThemeData(
                                                      backgroundColor:
                                                          surfaceColor,
                                                      hourMinuteTextColor:
                                                          primaryColor,
                                                      hourMinuteColor:
                                                          hourMinuteBg,
                                                      dayPeriodTextColor:
                                                          primaryColor,
                                                      dayPeriodColor:
                                                          hourMinuteBg,
                                                      dialHandColor:
                                                          primaryColor,
                                                      dialBackgroundColor:
                                                          hourMinuteBg,
                                                      entryModeIconColor:
                                                          primaryColor,
                                                      helpTextStyle: TextStyle(
                                                        color: primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      hourMinuteTextStyle:
                                                          TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 28,
                                                            color: primaryColor,
                                                          ),
                                                      dayPeriodTextStyle:
                                                          TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                            color: primaryColor,
                                                          ),
                                                      dialTextStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        color: primaryColor,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              24,
                                                            ),
                                                      ),
                                                    ),
                                                    textButtonTheme:
                                                        TextButtonThemeData(
                                                          style: TextButton.styleFrom(
                                                            foregroundColor:
                                                                primaryColor,
                                                            textStyle:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ),
                                                    colorScheme: ColorScheme(
                                                      brightness:
                                                          isDark
                                                              ? Brightness.dark
                                                              : Brightness
                                                                  .light,
                                                      primary: primaryColor,
                                                      onPrimary: Colors.white,
                                                      secondary: primaryColor,
                                                      onSecondary: Colors.white,
                                                      error: Colors.red,
                                                      onError: Colors.white,

                                                      surface: surfaceColor,
                                                      onSurface: onSurfaceColor,
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _selectedTime = picked;
                                                _timeError = false;
                                              });
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        ListTile(
                                          title: Text(
                                            _selectedStartDate == null
                                                ? AppLocalizations.of(
                                                  context,
                                                )!.pickScheduleStartDate
                                                : "${AppLocalizations.of(context)!.startDate}: ${_selectedStartDate!.day.toString().padLeft(2, '0')}-${_selectedStartDate!.month.toString().padLeft(2, '0')}-${_selectedStartDate!.year}",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  _startDateError
                                                      ? Colors.red
                                                      : null,
                                            ),
                                          ),
                                          trailing: Icon(
                                            Icons.calendar_today,
                                            color:
                                                _startDateError
                                                    ? Colors.red
                                                    : null,
                                          ),
                                          onTap: () async {
                                            final isDark =
                                                Theme.of(context).brightness ==
                                                Brightness.dark;
                                            final primaryColor = const Color(
                                              0xFF8AC249,
                                            );
                                            final surfaceColor =
                                                isDark
                                                    ? const Color(0xFF222222)
                                                    : Colors.white;
                                            final onSurfaceColor =
                                                isDark
                                                    ? Colors.white
                                                    : primaryColor;
                                            final now = DateTime.now();
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate:
                                                  _selectedStartDate ?? now,
                                              firstDate: now,
                                              lastDate: DateTime(now.year + 10),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(
                                                    context,
                                                  ).copyWith(
                                                    colorScheme: ColorScheme(
                                                      brightness:
                                                          isDark
                                                              ? Brightness.dark
                                                              : Brightness
                                                                  .light,
                                                      primary: primaryColor,
                                                      onPrimary: Colors.white,
                                                      secondary: primaryColor,
                                                      onSecondary: Colors.white,
                                                      error: Colors.red,
                                                      onError: Colors.white,
                                                      surface: surfaceColor,
                                                      onSurface: onSurfaceColor,
                                                    ),
                                                    textButtonTheme:
                                                        TextButtonThemeData(
                                                          style: TextButton.styleFrom(
                                                            foregroundColor:
                                                                primaryColor,
                                                            textStyle:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        ),
                                                    dialogTheme:
                                                        DialogThemeData(
                                                          backgroundColor:
                                                              surfaceColor,
                                                        ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _selectedStartDate = picked;
                                                _startDateError = false;
                                              });
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: RadioGroup<FrequencyType>(
                                            groupValue: _frequencyType,
                                            onChanged: (val) {
                                              setState(() {
                                                _frequencyType = val!;
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Radio<FrequencyType>(
                                                  value:
                                                      FrequencyType.everyXDays,
                                                  activeColor: const Color(
                                                    0xFF8AC249,
                                                  ),
                                                ),
                                                Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.everyXDays,
                                                  style: TextStyle(
                                                    color:
                                                        Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Radio<FrequencyType>(
                                                  value:
                                                      FrequencyType.daysOfWeek,
                                                  activeColor: const Color(
                                                    0xFF8AC249,
                                                  ),
                                                ),
                                                Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.selectDaysOfWeek,
                                                  style: TextStyle(
                                                    color:
                                                        Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _frequencyType ==
                                                FrequencyType.daysOfWeek
                                            ? Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.selectDaysOfWeek,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        color:
                                                            _daysOfWeekError
                                                                ? Colors.red
                                                                : null,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 8),
                                                _buildWeekdayPicker(),
                                              ],
                                            )
                                            : TextField(
                                              controller: frequencyController,
                                              cursorColor: Color(0xFF8AC249),
                                              keyboardType:
                                                  TextInputType.number,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              onChanged: (value) {
                                                if (_frequencyError &&
                                                    value.isNotEmpty &&
                                                    convertArabicNumerals(
                                                          value,
                                                        ) !=
                                                        '0') {
                                                  setState(
                                                    () =>
                                                        _frequencyError = false,
                                                  );
                                                }
                                              },
                                              decoration: InputDecoration(
                                                labelText:
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.frequency,
                                                labelStyle: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.copyWith(
                                                  color:
                                                      _frequencyError
                                                          ? Colors.red
                                                          : (Theme.of(
                                                                    context,
                                                                  ).brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.white
                                                              : Colors.black),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                errorText:
                                                    _frequencyError
                                                        ? AppLocalizations.of(
                                                          context,
                                                        )!.dosageFrequencyGreaterThanZero
                                                        : null,
                                              ),
                                            ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final isEveryXDays =
                                                      _frequencyType ==
                                                      FrequencyType.everyXDays;
                                                  final isDaysOfWeek =
                                                      _frequencyType ==
                                                      FrequencyType.daysOfWeek;

                                                  setState(() {
                                                    _nameError = false;
                                                    _typeError = false;
                                                    _dosageError = false;
                                                    _amountError = false;
                                                    _frequencyError = false;
                                                    _timeError = false;
                                                    _startDateError = false;
                                                    _daysOfWeekError = false;
                                                  });
                                                  bool hasErrors = false;
                                                  if (nameController
                                                      .text
                                                      .isEmpty) {
                                                    setState(
                                                      () => _nameError = true,
                                                    );
                                                    hasErrors = true;
                                                  }
                                                  if (typeOfMedicationController
                                                      .text
                                                      .isEmpty) {
                                                    setState(
                                                      () => _typeError = true,
                                                    );
                                                    hasErrors = true;
                                                  }
                                                  if (dosageController
                                                      .text
                                                      .isEmpty) {
                                                    setState(
                                                      () => _dosageError = true,
                                                    );
                                                    hasErrors = true;
                                                  }
                                                  if (amountController
                                                      .text
                                                      .isEmpty) {
                                                    setState(
                                                      () => _amountError = true,
                                                    );
                                                    hasErrors = true;
                                                  }
                                                  if (_selectedTime == null) {
                                                    setState(
                                                      () => _timeError = true,
                                                    );
                                                    hasErrors = true;
                                                  }
                                                  if (_selectedStartDate ==
                                                      null) {
                                                    setState(
                                                      () =>
                                                          _startDateError =
                                                              true,
                                                    );
                                                    hasErrors = true;
                                                  }
                                                  if (isEveryXDays &&
                                                      frequencyController
                                                          .text
                                                          .isEmpty) {
                                                    setState(
                                                      () =>
                                                          _frequencyError =
                                                              true,
                                                    );
                                                    hasErrors = true;
                                                  }
                                                  if (isDaysOfWeek &&
                                                      _selectedDaysOfWeek
                                                          .isEmpty) {
                                                    setState(
                                                      () =>
                                                          _daysOfWeekError =
                                                              true,
                                                    );
                                                    hasErrors = true;
                                                  }

                                                  if (hasErrors) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        backgroundColor:
                                                            Colors.red,
                                                        content: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.pleaseFillAllFields,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: 'Inter',
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  if (convertArabicNumerals(
                                                        dosageController.text,
                                                      ).isEmpty ||
                                                      convertArabicNumerals(
                                                        amountController.text,
                                                      ).isEmpty ||
                                                      convertArabicNumerals(
                                                            dosageController
                                                                .text,
                                                          ) ==
                                                          '0' ||
                                                      (isEveryXDays &&
                                                          (convertArabicNumerals(
                                                                frequencyController
                                                                    .text,
                                                              ).isEmpty ||
                                                              convertArabicNumerals(
                                                                    frequencyController
                                                                        .text,
                                                                  ) ==
                                                                  '0'))) {
                                                    setState(() {
                                                      if (convertArabicNumerals(
                                                                dosageController
                                                                    .text,
                                                              ) ==
                                                              '0' ||
                                                          convertArabicNumerals(
                                                            dosageController
                                                                .text,
                                                          ).isEmpty) {
                                                        _dosageError = true;
                                                      }
                                                      if (isEveryXDays &&
                                                          (convertArabicNumerals(
                                                                    frequencyController
                                                                        .text,
                                                                  ) ==
                                                                  '0' ||
                                                              convertArabicNumerals(
                                                                frequencyController
                                                                    .text,
                                                              ).isEmpty)) {
                                                        _frequencyError = true;
                                                      }
                                                    });
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        backgroundColor:
                                                            Colors.red,
                                                        content: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.dosageFrequencyGreaterThanZero,
                                                          style: Theme.of(
                                                                context,
                                                              )
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Inter',
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  if (_selectedStartDate ==
                                                      null) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        backgroundColor:
                                                            Colors.red,
                                                        content: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.pleasePickScheduleStartDate,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: 'Inter',
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  try {
                                                    if (widget.docId != null) {
                                                      await firestore.collection(widget.uid).doc(widget.docId).update({
                                                        'name':
                                                            nameController.text,
                                                        'typeOfMedication':
                                                            typeOfMedicationController
                                                                .text,
                                                        'dosage':
                                                            double.tryParse(
                                                              convertArabicNumerals(
                                                                dosageController
                                                                    .text,
                                                              ),
                                                            ) ??
                                                            0,
                                                        'frequency':
                                                            _frequencyType ==
                                                                    FrequencyType
                                                                        .everyXDays
                                                                ? (int.tryParse(
                                                                      convertArabicNumerals(
                                                                        frequencyController
                                                                            .text,
                                                                      ),
                                                                    ) ??
                                                                    1)
                                                                : 1,
                                                        'amount':
                                                            double.tryParse(
                                                              convertArabicNumerals(
                                                                amountController
                                                                    .text,
                                                              ),
                                                            ) ??
                                                            0,
                                                        'notifyTime':
                                                            _selectedTime !=
                                                                    null
                                                                ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                                                : '',
                                                        'startDate':
                                                            _selectedStartDate!
                                                                .toIso8601String(),
                                                        'daysOfWeek':
                                                            _frequencyType ==
                                                                    FrequencyType
                                                                        .daysOfWeek
                                                                ? _selectedDaysOfWeek
                                                                : null,
                                                        'refillThreshold':
                                                            refillThresholdController
                                                                    .text
                                                                    .isNotEmpty
                                                                ? double.tryParse(
                                                                  convertArabicNumerals(
                                                                    refillThresholdController
                                                                        .text,
                                                                  ),
                                                                )
                                                                : null,
                                                        'refillNotified': false,
                                                      });
                                                      final updatedDoc =
                                                          await firestore
                                                              .collection(
                                                                widget.uid,
                                                              )
                                                              .doc(widget.docId)
                                                              .get();
                                                      final updatedMedication =
                                                          medicationFromDoc(
                                                            updatedDoc,
                                                          );
                                                      await scheduleMedicationNotification(
                                                        context,
                                                        widget.docId!,
                                                        updatedMedication,
                                                        userId: widget.uid,
                                                      );
                                                    } else {
                                                      final docRef = await firestore.collection(widget.uid).add({
                                                        'name':
                                                            nameController.text,
                                                        'typeOfMedication':
                                                            typeOfMedicationController
                                                                .text,
                                                        'dosage':
                                                            double.tryParse(
                                                              convertArabicNumerals(
                                                                dosageController
                                                                    .text,
                                                              ),
                                                            ) ??
                                                            0,
                                                        'frequency':
                                                            _frequencyType ==
                                                                    FrequencyType
                                                                        .everyXDays
                                                                ? (int.tryParse(
                                                                      convertArabicNumerals(
                                                                        frequencyController
                                                                            .text,
                                                                      ),
                                                                    ) ??
                                                                    1)
                                                                : 1,
                                                        'amount':
                                                            double.tryParse(
                                                              convertArabicNumerals(
                                                                amountController
                                                                    .text,
                                                              ),
                                                            ) ??
                                                            0,
                                                        'notifyTime':
                                                            _selectedTime !=
                                                                    null
                                                                ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                                                : '',
                                                        'startDate':
                                                            _selectedStartDate!
                                                                .toIso8601String(),
                                                        'daysOfWeek':
                                                            _frequencyType ==
                                                                    FrequencyType
                                                                        .daysOfWeek
                                                                ? _selectedDaysOfWeek
                                                                : null,
                                                        'refillThreshold':
                                                            refillThresholdController
                                                                    .text
                                                                    .isNotEmpty
                                                                ? double.tryParse(
                                                                  convertArabicNumerals(
                                                                    refillThresholdController
                                                                        .text,
                                                                  ),
                                                                )
                                                                : null,
                                                        'refillNotified': false,
                                                      });
                                                      final newDoc =
                                                          await docRef.get();
                                                      final newMedication =
                                                          medicationFromDoc(
                                                            newDoc,
                                                          );
                                                      await scheduleMedicationNotification(
                                                        context,
                                                        docRef.id,
                                                        newMedication,
                                                        userId: widget.uid,
                                                      );
                                                    }
                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    Navigator.pop(context);
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        backgroundColor:
                                                            Colors.red,
                                                        content: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.couldNotSaveMedication,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Inter',
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(
                                                    0xFF8AC249,
                                                  ),
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.saveMedication,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        );
      },
    );
  }

  Widget _buildWeekdayPicker() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final daysAr = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final days = isArabic ? daysAr : daysEn;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(7, (i) {
        final dayNum = i == 0 ? 7 : i;
        return FilterChip(
          label: Text(
            days[i],
            style: TextStyle(
              color:
                  _selectedDaysOfWeek.contains(dayNum)
                      ? const Color(0xFF8AC249)
                      : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          selected: _selectedDaysOfWeek.contains(dayNum),
          backgroundColor:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF222222)
                  : Colors.white,
          selectedColor:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF8AC249).withValues(alpha: 0.25)
                  : const Color(0xFF8AC249).withValues(alpha: 0.12),
          checkmarkColor: const Color(0xFF8AC249),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color:
                  _selectedDaysOfWeek.contains(dayNum)
                      ? const Color(0xFF8AC249)
                      : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white24
                      : Colors.black12,
              width: _selectedDaysOfWeek.contains(dayNum) ? 2 : 1,
            ),
          ),
          elevation: _selectedDaysOfWeek.contains(dayNum) ? 3 : 1,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.comfortable,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDaysOfWeek.add(dayNum);
                _selectedDaysOfWeek.sort((a, b) {
                  if (a == 7 && b != 7) return -1;
                  if (a != 7 && b == 7) return 1;
                  return a.compareTo(b);
                });
              } else {
                _selectedDaysOfWeek.remove(dayNum);
              }
              if (_daysOfWeekError && _selectedDaysOfWeek.isNotEmpty) {
                _daysOfWeekError = false;
              }
            });
          },
        );
      }),
    );
  }
}
