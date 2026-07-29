import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n_extensions.dart';
import '../../../theme/colors/app_colors.dart';
import '../application/speech_assistant_controller.dart';
import '../application/speech_assistant_state.dart';
import '../application/speech_voice_provider.dart';

class SpeechVoiceSelector extends StatelessWidget {
  const SpeechVoiceSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<SpeechVoiceProvider>();
    final speechController = context.watch<SpeechAssistantController>();
    final isPreviewBusy = speechController.state.status ==
            SpeechAssistantStatus.generatingSpeech ||
        speechController.state.status == SpeechAssistantStatus.playingSpeech;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assistantVoice,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.assistantVoiceDescription,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: SpeechVoiceProvider.options.map((voice) {
            final selected = provider.selectedVoice.id == voice.id;
            final description = voice.isFemale
                ? l10n.assistantFemaleVoice
                : l10n.assistantMaleVoice;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: voice == SpeechVoiceProvider.options.first ? 8 : 0,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => provider.selectVoice(voice),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryColor.withValues(alpha: 0.16)
                          : AppColors.surfaceInput,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryColor
                            : AppColors.borderSubtle,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          voice.isFemale ? TablerIcons.woman : TablerIcons.man,
                          color: selected
                              ? AppColors.primaryColor
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          voice.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: isPreviewBusy
                              ? null
                              : () async {
                                  await provider.selectVoice(voice);
                                  if (!context.mounted) return;
                                  await context
                                      .read<SpeechAssistantController>()
                                      .generateAndPlaySpeech(
                                        l10n.assistantVoicePreviewMessage(
                                          voice.name,
                                        ),
                                      );
                                },
                          icon: isPreviewBusy && selected
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(TablerIcons.volume, size: 17),
                          label: Text(l10n.assistantVoicePreview),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
