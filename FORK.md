# Fork changelog

Customizations in [nick-otter-io/FluidAudio](https://github.com/nick-otter-io/FluidAudio) compared with upstream [FluidInference/FluidAudio](https://github.com/FluidInference/FluidAudio) `main`.

When merging upstream, update the base below and keep only the entries that are still fork-only.

## Base

- Upstream `main` at `e0c6103b` (2026-11-19): fix(build): bump podspec to 0.18.4

## Customizations

### English inflection stemming

`KokoroAneEnglishPhonemizer` builds regular plural, past, and `-ing` forms from a known lexicon stem before BART, matching Misaki `stem_s` / `stem_ed` / `stem_ing` (the `-'s` clitic was already upstream). A stored inflected form still wins. Unknown words still go to BART whole.

Covered by the inflection cases in `KokoroAneEnglishPhonemizerTests`.

Fork `main` first carried this as `1ceb18ae` (`feat: proper lexicon handling`) on an older upstream. It is still fork-only on the base above.

### Words sent to BART

English synthesis records the lowercased words that reached BART, in order, on `KokoroAneSynthesisResult.graphemeFallbackWords`. Other languages leave the list empty. Listen2Page reads it after each sentence and shows `BART word1 word2`.

`KokoroAneManager.logsGraphemeFallbackWords` (default on) also logs that list. The app calls `setLogsGraphemeFallbackWords(false)` and logs the words itself.

### Misaki and BART lookups

`KokoroAneManager.misakiPronunciation(for:)` returns the joined lexicon pronunciation for one spelling, without the custom lexicon, stemming, or BART. `bartPiecePronunciation(for:)` asks BART for one piece and rewrites the flap `ɾ` to `T`. Listen2Page uses both to reuse the loaded lexicon instead of reading the JSON itself.

### Speech highlight

English synthesis records `KokoroAneSynthesisResult.englishSegments`: each token's surface range in the phonemize argument and the phoneme scalars it emitted. Other languages, phoneme input, and `concatenating(_:)` leave the list empty; the text path assigns the full-string segments after chunks are joined. Listen2Page uses the ranges to highlight the word being spoken.
