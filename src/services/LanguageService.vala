public class LanguageService {
    static string preferred_language = "eng" ;

    static construct {
        Logger.info("Initializing LanguageService");
        // Automatically detect system language on startup
        detect_system_language();
        Logger.info(@"LanguageService initialized with language: $(preferred_language)");
    }

    private static void detect_system_language() {
        // Get the system locale
        string? locale = Environment.get_variable("LANG");
        Logger.debug(@"Detecting system language from LANG variable: $(locale ?? "null")");
        if (locale != null) {
            if (locale.has_prefix("ru")) {
                preferred_language = "rus";  // Russian
                Logger.info("Detected Russian language preference");
            } else if (locale.has_prefix("en")) {
                preferred_language = "eng";  // English
                Logger.info("Detected English language preference");
            } else {
                Logger.info(@"Using default English language (no match found for: $(locale))");
            }
            // Add more language detection here if needed
        } else {
            Logger.warn("LANG environment variable not set, using default English");
        }
    }

    public void save_pref_language (string language) {
        Logger.info(@"Saving preferred language: $(language)");
        preferred_language = language ;
    }

    public string get_pref_language () {
        Logger.debug(@"Retrieving preferred language: $(preferred_language)");
        return preferred_language ;
    }
}
