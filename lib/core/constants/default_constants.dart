class DefaultConstants {
  static const String mapBoxLight = "mapbox://styles/mapbox/satellite-streets-v12";
  static const String mapBoxDark = "mapbox://styles/mapbox/satellite-streets-v12";

  static const addressNeedStep = 1;
  static const userInfoNeedStep = 2;
  static const propertyNeedStep = 3;
  static const communityNeedStep = 4;
  static const imageQuality = 80;
  static const Map<String, String> propertyTypeOptions = {
    'PRIVATE_HOUSE': 'Частный дом',
    'TOWNHOUSE': 'Таунхауз',
    'COTTAGE': 'Дача',
    'LAND': 'Участок',
  };
  static const Map<String, String> resourceTypeOptions = {
    'WELL': 'Скважина',
    'GENERATOR': 'Генератор',
    'SEPTIC': 'Септик',
    'OTHER': 'Другая',
  };
  static const verified = "VERIFIED";
  static const unverified = "UNVERIFIED";

  static const Map<String, String> verificationStatus = {
    verified: 'Подтвержден',
    unverified: 'Не подтвержден',
  };
  static const license = "license";
  static const privacy = "privacy";
  static const event = "EVENT";
  static const notification = "NOTIFICATION";
}
