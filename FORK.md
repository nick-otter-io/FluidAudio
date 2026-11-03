# Fork changelog

Customizations in [nick-otter-io/FluidAudio](https://github.com/nick-otter-io/FluidAudio) compared with upstream [FluidInference/FluidAudio](https://github.com/FluidInference/FluidAudio) `main`.

When merging upstream, update the base below and keep only the entries that are still fork-only.

## Base

- Upstream `main` at `c3881073` (2026-09-30): docs: add Meetly to app showcase (#969)

## Customizations

### English inflection stemming

`KokoroAneEnglishPhonemizer` builds regular plural, past, and `-ing` forms from a known lexicon stem before BART, matching Misaki `stem_s` / `stem_ed` / `stem_ing` (the `-'s` clitic was already upstream). A stored inflected form still wins. Unknown words still go to BART whole.

Covered by the inflection cases in `KokoroAneEnglishPhonemizerTests`.

Fork `main` first carried this as `1ceb18ae` (`feat: proper lexicon handling`) on an older upstream. This branch replays it on the base above.

### Words sent to BART

English synthesis records the lowercased words that reached BART, in order, on `KokoroAneSynthesisResult.graphemeFallbackWords`. Other languages leave the list empty. Listen2Page reads it after each sentence and shows `BART word1 word2`.

`KokoroAneManager.logsGraphemeFallbackWords` (default on) also logs that list. The app calls `setLogsGraphemeFallbackWords(false)` and logs the words itself.
