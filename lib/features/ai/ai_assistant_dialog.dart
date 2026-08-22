import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/gemini_assistant_service.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class AIAssistantDialog extends ConsumerStatefulWidget {
  const AIAssistantDialog({super.key});

  @override
  ConsumerState<AIAssistantDialog> createState() => _AIAssistantDialogState();
}

class _AIAssistantDialogState extends ConsumerState<AIAssistantDialog> {
  final _aiService = GeminiAssistantService();
  final _promptController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Dayflow AI Intelligence Assistant', style: AppTypography.sectionHeading),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(),

              // Chat History
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Ask Dayflow AI about workforce metrics, attendance rates, leave requests, or payroll summaries.',
                          style: AppTypography.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _messages.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg['role'] == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkBackground : AppColors.lightSurface),
                                borderRadius: AppRadius.borderMd,
                              ),
                              child: Text(
                                msg['text'] ?? '',
                                style: AppTypography.bodySmall.copyWith(
                                  color: isUser ? Colors.white : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Input Row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      hintText: 'Ask AI assistant (e.g. "Workforce headcount")...',
                      controller: _promptController,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AppButton(
                    label: 'Ask',
                    isLoading: _isLoading,
                    onPressed: _sendPrompt,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final session = ref.read(authNotifierProvider).state;
    if (session.activeOrganization == null) return;

    setState(() {
      _messages.add({'role': 'user', 'text': prompt});
      _promptController.clear();
      _isLoading = true;
    });

    try {
      final response = await _aiService.askAssistant(
        organizationId: session.activeOrganization!.id,
        prompt: prompt,
      );

      setState(() {
        _messages.add({'role': 'ai', 'text': response});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'text': 'Error: ${e.toString()}'});
        _isLoading = false;
      });
    }
  }
}
