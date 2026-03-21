class ErrorMessages {
  static String serverError(int code) =>
      'Server error ($code). Coba beberapa saat lagi.';

  static const String parseError =
      'Tidak dapat terhubung ke server. Periksa koneksi internet kamu.';

  static const String noInternet =
      'Tidak ada koneksi internet. Periksa jaringan kamu.';

  static const String cannotConnect = 'Tidak dapat terhubung ke server.';
}
