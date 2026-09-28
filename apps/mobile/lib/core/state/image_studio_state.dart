import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneratedImage {
  const GeneratedImage({required this.seedColor, required this.prompt});

  final Color seedColor;
  final String prompt;
}

class ImageStudioState {
  const ImageStudioState({this.isGenerating = false, this.variations = const []});

  final bool isGenerating;
  final List<GeneratedImage> variations;

  ImageStudioState copyWith({bool? isGenerating, List<GeneratedImage>? variations}) {
    return ImageStudioState(
      isGenerating: isGenerating ?? this.isGenerating,
      variations: variations ?? this.variations,
    );
  }
}

const _palette = [Color(0xFF7C5CFC), Color(0xFF27C8E8), Color(0xFFF4B740), Color(0xFF35C98B)];

/// Drives Image Studio's generation canvas: a placeholder for the real
/// image-generation provider (DALL·E, Imagen, Stable Diffusion, etc.) — it
/// "generates" a set of color-swatch placeholders after a scripted delay so
/// the canvas, variations history, and result actions can be built and
/// tested end-to-end.
class ImageStudioController extends StateNotifier<ImageStudioState> {
  ImageStudioController() : super(const ImageStudioState());

  Future<void> generate(String prompt) async {
    state = state.copyWith(isGenerating: true);
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final newVariations = [
      for (final color in _palette) GeneratedImage(seedColor: color, prompt: prompt),
      ...state.variations,
    ];
    state = ImageStudioState(isGenerating: false, variations: newVariations);
  }
}

final imageStudioControllerProvider = StateNotifierProvider<ImageStudioController, ImageStudioState>((ref) {
  return ImageStudioController();
});
