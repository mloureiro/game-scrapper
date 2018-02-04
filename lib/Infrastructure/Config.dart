import 'dart:convert';
import 'dart:io';

class Config {
  Map _config;
  String _configPath;

  Config(this._configPath) {
    _config = _setup(_configPath);
  }

  dynamic get(String path) =>
    _get(_config, path.split('.'));

  void set(String path, value) =>
    _set(_config, path.split('.'), value);

  void store() {
    File file = new File(_configPath);
    if (!file.existsSync()) {
      file.createSync();
    }

    file.writeAsStringSync(JSON.encode(_config), flush: true);
  }

  dynamic _get(Map config, List<String> path) {
    if (path.isEmpty) {
      return null;
    }

    String key = path.first;
    path.removeAt(0);
    if (!_isConfigKeyValid(config, key, path)) {
      return null;
    }

    return path.length > 0
      ? _get(config[key], path)
      : config[key];
  }

  void _set(Map config, List<String> path, value) {
    Map current = config;
    for (int i = 0; i + 1 < path.length; i++) {
      current[path[i]] = {};
      current = current[path[i]];
    }
    current[path.last] = value;
  }

  Map _setup(String filePath) {
    File file = new File(filePath);

    return file.existsSync()
      ? JSON.decode(file.readAsStringSync())
      : {};
  }

  String toString() =>
    _config.toString();

  bool _isConfigKeyValid(Map config, String key, List<String> path) =>
    config.containsKey(key) && (path.isEmpty || config[key] is Map);
}
