class ApiUrls {
  static const String baseUrl = 'http://localhost:7000/api';

  // Auth URLs
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';

  // Livreur URLs
  static const String livreurs = '$baseUrl/livreurs';

    static const String deliveries = '$baseUrl/deliveries';

  // Exemple d'URL avec un paramètre
  static String getLivreurDetails(String id) => '$baseUrl/livreurs/$id';
}
