abstract class Assets {
  static final icons = _Icons();
  static final images = _Images();
  static final lotties = _Lotties();
}

class _Icons {
  static const _basePath = 'assets/icons';
  final iconMap = '$_basePath/icon_map.svg';
  final location = '$_basePath/location.svg';
  final home = '$_basePath/home_icon.svg';
  final messages = '$_basePath/messages.svg';
  final option = '$_basePath/option.svg';
  final edit = '$_basePath/edit.svg';
  final share = '$_basePath/share.svg';
  final check = '$_basePath/check.svg';
  final delete = '$_basePath/delete.svg';
  final stars = '$_basePath/stars.svg';
  final bell = '$_basePath/bell.svg';
  final balloon = '$_basePath/balloon.svg';
  final sirenRounded = '$_basePath/siren_rounded.svg';
  final shieldUp = '$_basePath/shield_up.svg';
  final reset = '$_basePath/reset.svg';
  final notificationUnread = '$_basePath/notification_unread.svg';
  final pinList = '$_basePath/pin_list.svg';
  final warning = '$_basePath/warning.svg';
  final rowVertical = '$_basePath/row-vertical.svg';
}

class _Images {
  static const _basePath = 'assets/images';
  final square = '$_basePath/square.png';
}

class _Lotties {
  static const _basePath = 'assets/lotties';
  final warning = '$_basePath/warning_animation.json';
  final notFound = '$_basePath/not_found.json';
}
