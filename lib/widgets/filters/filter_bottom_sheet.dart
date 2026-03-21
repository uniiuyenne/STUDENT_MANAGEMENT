import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class FilterBottomSheet extends StatefulWidget {
  final String initialClass;
  final String initialDept;
  final double? initialGpa;
  final Function(String classFilter, String deptFilter, double? gpaFilter) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialClass,
    required this.initialDept,
    required this.initialGpa,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String tempClass;
  late String tempDept;
  late double? tempGpa;

  @override
  void initState() {
    super.initState();
    tempClass = widget.initialClass;
    tempDept = widget.initialDept;
    tempGpa = widget.initialGpa;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter students',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: tempClass),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return AppConstants.classes;
                  }
                  return AppConstants.classes.where(
                    (option) => option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    ),
                  );
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Lớp:',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        tempClass = value;
                      });
                    },
                  );
                },
                onSelected: (selection) {
                  setModalState(() {
                    tempClass = selection;
                  });
                },
              ),
              const SizedBox(height: 12),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: tempDept),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return AppConstants.departments;
                  }
                  return AppConstants.departments.where(
                    (option) => option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    ),
                  );
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Khoa',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        tempDept = value;
                      });
                    },
                  );
                },
                onSelected: (selection) {
                  setModalState(() {
                    tempDept = selection;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: tempGpa?.toString(),
                decoration: const InputDecoration(
                  labelText: 'Min GPA',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setModalState(() {
                    tempGpa = value.isEmpty ? null : double.tryParse(value);
                  });
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onApply('', '', null);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(tempClass, tempDept, tempGpa);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
