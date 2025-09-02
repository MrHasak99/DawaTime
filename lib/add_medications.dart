import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawatime/main.dart';
import 'package:flutter/material.dart';
import 'package:dawatime/home_page.dart' hide requestExactAlarmPermission;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dawatime/login_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dawatime/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;

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
  TimeOfDay? _selectedTime;
  DateTime? _selectedStartDate;
  List<int> _selectedDaysOfWeek = [];
  FrequencyType _frequencyType = FrequencyType.everyXDays;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      nameController.text = widget.medication!.name;
      typeOfMedicationController.text = widget.medication!.typeOfMedication;
      dosageController.text = widget.medication!.dosage.toString();
      frequencyController.text = widget.medication!.frequency.toString();
      amountController.text = widget.medication!.amount.toString();
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
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc =
              await FirebaseFirestore.instance
                  .collection(user.uid)
                  .doc(response.payload!)
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
      future: FirebaseFirestore.instance.collection(user.uid).get(),
      builder: (context, snapshot) {
        final medicationCount = snapshot.data?.docs.length ?? 0;
        final isAtLimit = medicationCount >= 7;

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
                            Icon(Icons.warning, color: Colors.red, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.youCanOnlyHaveUpTo7Medications,
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
                                          decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(
                                                  context,
                                                )!.name,
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
                                        TextField(
                                          controller:
                                              typeOfMedicationController,
                                          cursorColor: Color(0xFF8AC249),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(
                                                  context,
                                                )!.unitOfMeasurement,
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
                                        TextField(
                                          controller: dosageController,
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
                                                )!.dosage,
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
                                        TextField(
                                          controller: amountController,
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
                                                )!.currentAmount,
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
                                            ),
                                          ),
                                          trailing: Icon(Icons.access_time),
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
                                            ),
                                          ),
                                          trailing: Icon(Icons.calendar_today),
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
                                              });
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Radio<FrequencyType>(
                                                value: FrequencyType.everyXDays,
                                                groupValue: _frequencyType,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _frequencyType = val!;
                                                  });
                                                },
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
                                                value: FrequencyType.daysOfWeek,
                                                groupValue: _frequencyType,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _frequencyType = val!;
                                                  });
                                                },
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
                                              decoration: InputDecoration(
                                                labelText:
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.frequency,
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

                                                  final allFieldsFilled =
                                                      nameController
                                                          .text
                                                          .isNotEmpty &&
                                                      typeOfMedicationController
                                                          .text
                                                          .isNotEmpty &&
                                                      dosageController
                                                          .text
                                                          .isNotEmpty &&
                                                      amountController
                                                          .text
                                                          .isNotEmpty &&
                                                      _selectedTime != null &&
                                                      _selectedStartDate !=
                                                          null &&
                                                      ((isEveryXDays &&
                                                              frequencyController
                                                                  .text
                                                                  .isNotEmpty) ||
                                                          (isDaysOfWeek &&
                                                              _selectedDaysOfWeek
                                                                  .isNotEmpty));

                                                  if (!allFieldsFilled) {
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
                                                                ? int.tryParse(
                                                                      convertArabicNumerals(
                                                                        frequencyController
                                                                            .text,
                                                                      ),
                                                                    ) ??
                                                                    0
                                                                : 0,
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
                                                                    .join(',')
                                                                : '',
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
                                                            int.tryParse(
                                                              convertArabicNumerals(
                                                                frequencyController
                                                                    .text,
                                                              ),
                                                            ) ??
                                                            0,
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
                                                            _selectedDaysOfWeek
                                                                .join(','),
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

  String convertArabicNumerals(String input) {
    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < arabicNums.length; i++) {
      input = input.replaceAll(arabicNums[i], i.toString());
    }
    return input;
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
              fontSize: 16,
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
            borderRadius: BorderRadius.circular(16),
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
          elevation: _selectedDaysOfWeek.contains(dayNum) ? 4 : 0,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDaysOfWeek.add(dayNum);
              } else {
                _selectedDaysOfWeek.remove(dayNum);
              }
            });
          },
        );
      }),
    );
  }
}

Future<void> scheduleMedicationNotification(
  BuildContext? context,
  String docId,
  Medications medication, {
  bool forceNextDay = false,
}) async {
  await requestExactAlarmPermission();
  if (medication.notifyTime == null || medication.notifyTime!.isEmpty) return;
  final timeParts = medication.notifyTime!.split(':');
  if (timeParts.length != 2) return;
  final hour = int.tryParse(timeParts[0]);
  final minute = int.tryParse(timeParts[1]);
  if (hour == null || minute == null) return;

  for (int i = 0; i <= 8; i++) {
    await flutterLocalNotificationsPlugin.cancel(docId.hashCode + i);
  }

  final now = DateTime.now();
  final daysOfWeek = medication.daysOfWeek ?? [];

  if (daysOfWeek.isNotEmpty) {
    final now = DateTime.now();
    for (final weekday in daysOfWeek) {
      int daysUntil = (weekday - now.weekday) % 7;
      if (daysUntil <= 0) daysUntil += 7;
      final nextDate = now.add(Duration(days: daysUntil));
      final scheduledTime = DateTime(
        nextDate.year,
        nextDate.month,
        nextDate.day,
        hour,
        minute,
      );
      if (scheduledTime.isAfter(now)) {
        for (int j = 0; j <= 8; j++) {
          final followUpTime = scheduledTime.add(Duration(minutes: 15 * j));
          final scheduledTZ = tz.TZDateTime.from(followUpTime, tz.local);
          final notificationId = ('${docId}_${weekday}_$j').hashCode;
          final notificationMessage =
              j == 0
                  ? AppLocalizations.of(
                    context ?? navigatorKey.currentContext!,
                  )!.timeToTakeMedication(medication.name)
                  : AppLocalizations.of(
                    context ?? navigatorKey.currentContext!,
                  )!.reminderTakeMedication(medication.name);

          await flutterLocalNotificationsPlugin.zonedSchedule(
            notificationId,
            medication.name,
            notificationMessage,
            scheduledTZ,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'medication_channel_$docId',
                'Medication Reminders for ${medication.name}',
                channelDescription: 'Reminds you to take ${medication.name}',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                icon: 'dawatime_notify',
                sound: RawResourceAndroidNotificationSound(
                  'notification_sound',
                ),
                color: const Color(0xFF8AC249),
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentSound: true,
                presentBadge: true,
                sound: "notification_sound.wav",
              ),
            ),
            payload: docId,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    }
    return;
  }

  DateTime baseDate =
      medication.startDate != null
          ? DateTime(
            medication.startDate!.year,
            medication.startDate!.month,
            medication.startDate!.day,
            hour,
            minute,
          )
          : DateTime(now.year, now.month, now.day, hour, minute);

  var scheduledTime = baseDate;
  while (scheduledTime.isBefore(now)) {
    scheduledTime = scheduledTime.add(Duration(days: medication.frequency));
  }

  try {
    if (scheduledTime.isAfter(now)) {
      for (int i = 0; i <= 8; i++) {
        final followUpTime = scheduledTime.add(Duration(minutes: 15 * i));
        final notificationMessage =
            i == 0
                ? AppLocalizations.of(
                  context ?? navigatorKey.currentContext!,
                )!.timeToTakeMedication(medication.name)
                : AppLocalizations.of(
                  context ?? navigatorKey.currentContext!,
                )!.reminderTakeMedication(medication.name);

        final scheduledTZ = tz.TZDateTime.from(followUpTime, tz.local);
        final notificationId = ('${docId}_$i').hashCode;

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          medication.name,
          notificationMessage,
          scheduledTZ,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_channel_$docId',
              'Medication Reminders for ${medication.name}',
              channelDescription: 'Reminds you to take ${medication.name}',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              icon: 'dawatime_notify',
              sound: RawResourceAndroidNotificationSound('notification_sound'),
              color: const Color(0xFF8AC249),
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
              presentBadge: true,
              sound: "notification_sound.wav",
            ),
          ),
          payload: docId,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  } catch (e) {
    if (context != null) {
      if (e is PlatformException && e.code == 'exact_alarms_not_permitted') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF8AC249),
            content: Text(
              AppLocalizations.of(context)!.allowSettings,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.openSettings,
              onPressed: openExactAlarmSettings,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF8AC249),
            content: Text(
              '${AppLocalizations.of(context)!.scheduleMedicationFailure} $e',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        );
      }
    }
  }
}
