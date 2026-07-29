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
    final isGenerating =
        speechController.state.status == SpeechAssistantStatus.generatingSpeech;

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
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: SpeechVoiceProvider.options.map((voice) {
                final selected = provider.selectedVoice.id == voice.id;
                final isActivePreview =
                    speechController.previewVoiceId == voice.id;
                return SizedBox(
                  width: constraints.maxWidth,
                  height: 230,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => provider.selectVoice(voice),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(12),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            switch (voice.gender) {
                              SpeechVoiceGender.female => TablerIcons.woman,
                              SpeechVoiceGender.male => TablerIcons.man,
                              SpeechVoiceGender.neutral => TablerIcons.user,
                            },
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
                            voice.description,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (isActivePreview)
                            _VoiceMiniPlayer(controller: speechController)
                          else
                            TextButton.icon(
                              onPressed: isGenerating
                                  ? null
                                  : () => _startPreview(
                                        context,
                                        provider,
                                        voice,
                                      ),
                              icon: isGenerating && selected
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(TablerIcons.player_play,
                                      size: 17),
                              label: Text(l10n.assistantVoicePreview),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryColor,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        if (speechController.state.status == SpeechAssistantStatus.failure &&
            speechController.state.errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            speechController.state.errorMessage!,
            style: const TextStyle(
              color: AppColors.errorColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _startPreview(
    BuildContext context,
    SpeechVoiceProvider provider,
    SpeechVoiceOption voice,
  ) async {
    await provider.selectVoice(voice);
    if (!context.mounted) return;
    await context.read<SpeechAssistantController>().playVoicePreview(
          voiceId: voice.id,
          text: context.l10n.assistantVoicePreviewMessage,
        );
  }
}

class _VoiceMiniPlayer extends StatelessWidget {
  const _VoiceMiniPlayer({required this.controller});

  final SpeechAssistantController controller;

  @override
  Widget build(BuildContext context) {
    final durationMs = controller.previewDuration.inMilliseconds;
    final positionMs = controller.previewPosition.inMilliseconds
        .clamp(0, durationMs > 0 ? durationMs : 1);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: controller.previewPlaying ? 'Pausar' : 'Reproducir',
              onPressed: controller.previewPlaying
                  ? controller.pauseVoicePreview
                  : () => controller.playVoicePreview(
                        voiceId: controller.previewVoiceId!,
                        text: context.l10n.assistantVoicePreviewMessage,
                      ),
              icon: Icon(
                controller.previewPlaying
                    ? TablerIcons.player_pause
                    : TablerIcons.player_play,
                size: 20,
              ),
            ),
            Expanded(
              child: Slider(
                value: positionMs.toDouble(),
                max: (durationMs > 0 ? durationMs : 1).toDouble(),
                onChanged: durationMs == 0
                    ? null
                    : (value) => controller.seekVoicePreview(
                          Duration(milliseconds: value.round()),
                        ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Detener',
              onPressed: controller.stopVoicePreview,
              icon: const Icon(TablerIcons.player_stop, size: 20),
            ),
          ],
        ),
        Text(
          '${_format(controller.previewPosition)} / '
          '${_format(controller.previewDuration)}',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }

  static String _format(Duration duration) {
    final seconds = duration.inSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}
