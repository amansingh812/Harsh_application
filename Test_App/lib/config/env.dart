enum EnvType { local, staging, production }

class Env {
  static EnvType current = EnvType.local;

  static String get baseIP {
    switch (current) {
      case EnvType.local:
        return "http://192.168.0.3:8086";
      case EnvType.staging:
        return "https://staging.schoolscout.in";
      case EnvType.production:
        return "https://myschoolscout.in:8443";
    }
  }

  static bool get enableSslPinning =>
      current == EnvType.production;
}
