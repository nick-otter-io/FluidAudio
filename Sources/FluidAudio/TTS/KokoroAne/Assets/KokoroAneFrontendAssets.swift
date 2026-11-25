#if TTS
import Foundation

/// Downloads the text-frontend files a variant reads before its first sentence.
/// Download only: nothing is loaded into memory, so this can run for a language that is not playing yet.
enum KokoroAneFrontendAssets {
    static func ensure(variant: KokoroAneVariant, repoDirectory: URL, directory: URL?) async throws {
        switch variant {
        case .english:
            try await KokoroAneResourceDownloader.ensureG2PAssets(directory: directory)
            _ = await KokoroAneResourceDownloader.ensureEnglishLexicon(directory: directory)
        case .mandarin:
            _ = try await KokoroAneResourceDownloader.ensureMandarinG2P(repoDirectory: repoDirectory)
            _ = await KokoroAneResourceDownloader.ensureMandarinJiebaHmm(repoDirectory: repoDirectory)
            _ = await KokoroAneResourceDownloader.ensureMandarinG2pw(repoDirectory: repoDirectory)
        case .japanese:
            _ = try await KokoroAneResourceDownloader.ensureJapaneseG2P(repoDirectory: repoDirectory)
        case .spanish:
            // Best effort, as in the store: without the lexicon the spelling rules still run.
            _ = try? await KokoroAneResourceDownloader.ensureLexiconCache(
                KokoroAneConstants.spanishLexiconCacheFile, directory: directory)
        case .french:
            _ = try await KokoroAneResourceDownloader.ensureLexiconCache(
                KokoroAneConstants.frenchLexiconCacheFile, directory: directory)
            try await KokoroAneResourceDownloader.ensureMultilingualG2PAssets(directory: directory)
        }
    }
}
#endif
