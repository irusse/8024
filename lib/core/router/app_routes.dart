abstract class AppRoutePath {
  static const home = '/';
  static const authWelcome = '/auth-welcome';
  static const splash = '/splash';
  static const login = '/login';
  static const propertyDetails = '/property-details/:propertyId';
  static const propertyEdit = 'edit';
  static const community = '/community/:communityId';
  static const resourceForm = 'resource-form';
  static const sms = '/sms/:phone';
  static const profile = '/profile';
  static const editProfile = 'edit';
  static const myEvents = 'my-events';
  static const noInternet = '/no_internet';
  static const unexpectedError = '/unexpected-error';
  static const notificationForm = '/notification-form';
  static const eventForm = '/event-form';
  static const eventDetails = '/event-details/:eventId';
  static const fullMapPreview = '/full-map-preview';
  static const propertyVerifications = 'property-verifications';
  static const documentPage = 'document-page/:key';
  static const chatListPage = '/chat-list-page';
  static const chatPage = 'chat-page/:eventId/:eventTitle';
  static const settingsPage = 'settings';
  static const deleteSmsCode = 'delete-sms-code';
  static const countryCodeSelect = '/countryCodeSelect';
  static const notifications = 'notifications';
}

abstract class AppRouteBuilder {
  static String documentPage(String key) =>
      '${AppRoutePath.profile}/document-page/$key';

  static String propertyDetails(int propertyId) =>
      '/property-details/$propertyId';

  static String chatPage(int eventId, String eventTitle) =>
      '${AppRoutePath.chatListPage}/${AppRoutePath.chatPage}'
          .replaceAll(
            ':eventId',
            eventId.toString(),
          )
          .replaceAll(
            ':eventTitle',
            Uri.encodeComponent(eventTitle),
          );

  static String propertyEdit(int propertyId) =>
      '/property-details/$propertyId/${AppRoutePath.propertyEdit}';

  static String eventDetails(int eventId) =>
      AppRoutePath.eventDetails.replaceAll(':eventId', eventId.toString());

  static String resourceForm(int propertyId) =>
      '/property-details/$propertyId/${AppRoutePath.resourceForm}';

  static String sms(String phone) => '/sms/$phone';

  static String community(int communityId) =>
      AppRoutePath.community.replaceAll(':communityId', communityId.toString());
}
