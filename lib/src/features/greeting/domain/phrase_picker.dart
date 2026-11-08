import 'dart:math';

const phraseCount = 12;

/// Índice 1-12 distinto de [lastIndex].
int pickPhraseIndex(Random rng, int lastIndex) {
  int i;
  do {
    i = rng.nextInt(phraseCount) + 1;
  } while (i == lastIndex);
  return i;
}
