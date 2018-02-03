import 'package:logging/logging.dart'
  show Level, Logger, LogRecord;

class Log {
  static const _LOGGER_NAME = 'some-random-name';

  static Logger _logger;

  static void alert(
    String message,
    { List<String> context, Object error }
  ) =>
    _log(message, Level.SHOUT, context: context, error: error);

  static void critical(
    String message,
    { List<String> context, Object error }
  ) =>
    _log(message, Level.SEVERE, context: context, error: error);

  static void warning(
    String message,
    { List<String> context, Object error }
  ) =>
    _log(message, Level.WARNING, context: context, error: error);

  static void notice(
    String message,
    { List<String> context, Object error }
  ) =>
    _log(message, Level.CONFIG, context: context, error: error);

  static void info(
    String message,
    { List<String> context, Object error }
  ) =>
    _log(message, Level.INFO, context: context, error: error);

  static void debug(
    String message,
    { List<String> context, Object error }
  ) =>
    _log(message, Level.FINE, context: context, error: error);

  static void _log(
    String message,
    Level level,
    { List<String> context, Object error }
  ) =>
    _getLogger().log(level, _makeMessage(message, context), error);

  static Logger _getLogger() {
    if (_logger == null) {
      _logger = _setupLogger();
    }

    return _logger;
  }

  static Logger _setupLogger() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('[${rec.level.name}] [${rec.time}]: ${rec.message}');
    });

    return new Logger(_LOGGER_NAME);
  }

  static String _makeMessage(
    String message,
    [List<String> context = const []]
  ) =>
    context.isNotEmpty
      ? '[${context.join('.')}] $message'
      : message;
}
