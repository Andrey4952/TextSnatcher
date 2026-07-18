public class Logger : Object {
    private static FileStream? log_file = null;
    private static LogLevel current_level = LogLevel.DEBUG;

    public enum LogLevel {
        DEBUG = 0,
        INFO = 1,
        WARN = 2,
        ERROR = 3
    }

    static construct {
        setup_logging();
    }

    private static void setup_logging() {
        try {
            string log_dir = Path.build_filename(Environment.get_user_cache_dir(), "textsnatcher");
            DirUtils.create_with_parents(log_dir, 0755);

            string timestamp = new DateTime.now().format("%Y%m%d_%H%M%S");
            string log_path = Path.build_filename(log_dir, @"textsnatcher_$timestamp.log");

            log_file = FileStream.open(log_path, "a");
            if (log_file != null) {
                info(@"Logger initialized. Log file: $(log_path)");
            }
        } catch (Error e) {
            stderr.printf("Failed to initialize logger: %s\n", e.message);
        }
    }

    private static void write_log(LogLevel level, string message) {
        if (level < current_level) {
            return;
        }

        string level_str = get_level_string(level);
        string timestamp = new DateTime.now().format("%Y-%m-%d %H:%M:%S");
        string log_message = @"[$timestamp] [$level_str] $message\n";

        stdout.printf("%s", log_message);

        if (log_file != null) {
            log_file.printf("%s", log_message);
            log_file.flush();
        }
    }

    private static string get_level_string(LogLevel level) {
        switch (level) {
            case LogLevel.DEBUG:
                return "DEBUG";
            case LogLevel.INFO:
                return "INFO";
            case LogLevel.WARN:
                return "WARN";
            case LogLevel.ERROR:
                return "ERROR";
            default:
                return "UNKNOWN";
        }
    }

    public static void debug(string message) {
        write_log(LogLevel.DEBUG, message);
    }

    public static void info(string message) {
        write_log(LogLevel.INFO, message);
    }

    public static void warn(string message) {
        write_log(LogLevel.WARN, message);
    }

    public static void error(string message) {
        write_log(LogLevel.ERROR, message);
    }

    public static void set_level(LogLevel level) {
        current_level = level;
    }
}