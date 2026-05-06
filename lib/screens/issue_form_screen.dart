import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/issue_model.dart';
import '../providers/issue_provider.dart';
import '../utils/validators.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_text_field.dart';
import '../widgets/attachment_picker_tile.dart';

class IssueFormScreen extends StatefulWidget {
  final IssueModel? issue;

  const IssueFormScreen({super.key, this.issue});

  @override
  State<IssueFormScreen> createState() => _IssueFormScreenState();
}

class _IssueFormScreenState extends State<IssueFormScreen> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController assigneeController;
  final imagePicker = ImagePicker();

  String priority = 'Medium';
  String status = 'Open';
  String? attachmentPath;

  bool get isEdit => widget.issue != null;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.issue?.title ?? '');
    descriptionController = TextEditingController(
      text: widget.issue?.description ?? '',
    );
    assigneeController = TextEditingController(
      text: widget.issue?.assignee ?? '',
    );

    priority = widget.issue?.priority ?? 'Medium';
    status = widget.issue?.status ?? 'Open';
    attachmentPath = widget.issue?.attachmentPath;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    assigneeController.dispose();
    super.dispose();
  }

  Future<void> saveIssue() async {
    if (!formKey.currentState!.validate()) return;

    final now = DateTime.now().toIso8601String();

    final issue = IssueModel(
      id: widget.issue?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      priority: priority,
      status: status,
      assignee: assigneeController.text.trim().isEmpty
          ? null
          : assigneeController.text.trim(),
      createdDate: widget.issue?.createdDate ?? now,
      updatedDate: now,
      attachmentPath: attachmentPath,
      isSynced: false,
    );

    if (isEdit) {
      await context.read<IssueProvider>().updateIssue(issue);
    } else {
      await context.read<IssueProvider>().addIssue(issue);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> pickAttachment() async {
    XFile? image;

    try {
      image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );
    } on PlatformException catch (error) {
      if (!mounted) return;

      final message = error.code == 'channel-error'
          ? 'Image picker is not ready. Stop and rebuild the app, then try again.'
          : 'Unable to pick image: ${error.message ?? error.code}';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    if (image == null || !mounted) return;

    final pickedImage = image;
    setState(() {
      attachmentPath = pickedImage.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Issue' : 'Create Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              AppTextField(
                controller: titleController,
                label: 'Title',
                validator: AppValidators.issueTitle,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: descriptionController,
                label: 'Description',
                maxLines: 4,
                validator: AppValidators.issueDescription,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const ['Low', 'Medium', 'High']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    priority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const ['Open', 'In Progress', 'Resolved', 'Closed']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: assigneeController,
                label: 'Assignee Optional',
              ),
              const SizedBox(height: 16),
              AttachmentPickerTile(
                attachmentPath: attachmentPath,
                onPick: pickAttachment,
                onRemove: () {
                  setState(() {
                    attachmentPath = null;
                  });
                },
              ),
              const SizedBox(height: 28),
              AppButton(
                text: isEdit ? 'Update Issue' : 'Create Issue',
                onPressed: saveIssue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
