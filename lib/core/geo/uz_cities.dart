/// O'zbekiston shaharlarining taxminiy markaziy koordinatalari.
///
/// Yuk yaratishda to'xtash nuqtasiga koordinata biriktirish uchun ishlatiladi —
/// backend yuklarni masofa bo'yicha qidiradi, koordinatasiz yuk hech qachon
/// qidiruv natijasiga tushmaydi.
///
/// Bu vaqtinchalik yechim: keyinchalik xaritadan nuqta tanlash yoki
/// geokodlash xizmati bilan almashtirilishi kerak.
class UzCities {
  const UzCities._();

  static const Map<String, (double, double)> _coordinates = {
    'toshkent': (41.2995, 69.2401),
    'samarqand': (39.6270, 66.9750),
    'buxoro': (39.7747, 64.4286),
    'namangan': (40.9983, 71.6726),
    'andijon': (40.7821, 72.3442),
    'farg\'ona': (40.3864, 71.7864),
    'fargona': (40.3864, 71.7864),
    'nukus': (42.4531, 59.6103),
    'qarshi': (38.8606, 65.7891),
    'termiz': (37.2242, 67.2783),
    'jizzax': (40.1158, 67.8422),
    'guliston': (40.4897, 68.7842),
    'navoiy': (40.1030, 65.3686),
    'urganch': (41.5500, 60.6333),
    'xiva': (41.3783, 60.3639),
    'sirdaryo': (40.8422, 68.6606),
    'chirchiq': (41.4689, 69.5822),
    'angren': (41.0167, 70.1436),
    'olmaliq': (40.8442, 69.5983),
    'bekobod': (40.2206, 69.2694),
    'kokand': (40.5286, 70.9425),
    'qo\'qon': (40.5286, 70.9425),
    'qoqon': (40.5286, 70.9425),
    'marg\'ilon': (40.4711, 71.7244),
    'margilon': (40.4711, 71.7244),
    'shahrisabz': (39.0553, 66.8300),
    'denov': (38.2683, 67.8931),
    'zarafshon': (41.5786, 64.2036),
  };

  /// Toshkent — nomi tanilmagan shahar uchun zaxira nuqta.
  static const (double, double) fallback = (41.2995, 69.2401);

  /// Shahar nomiga mos koordinatani qaytaradi. Nom tanilmasa `null`.
  static (double, double)? lookup(String city) {
    final key = city.trim().toLowerCase();
    if (key.isEmpty) return null;
    return _coordinates[key];
  }
}
