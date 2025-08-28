run-dev:
	fvm flutter run -t lib/main_dev.dart --dart-define=BASE_URL=https://dev-api.your-backend.com

run-prod:
	fvm flutter run -t lib/main_prod.dart --dart-define=BASE_URL=https://api.your-backend.com

build-dev:
	fvm flutter build apk -t lib/main_dev.dart --dart-define=BASE_URL=https://dev-api.your-backend.com

build-prod:
	fvm flutter build apk -t lib/main_prod.dart --dart-define=BASE_URL=https://api.your-backend.com

run-ios-dev:
	fvm flutter run -t lib/main_dev.dart -d E16B0446-092B-4B4B-9A0C-D0DC8AC9DC55 --dart-define=BASE_URL=https://dev-api.your-backend.com

run-ios-prod:
	fvm flutter run -t lib/main_prod.dart -d ios --dart-define=BASE_URL=https://api.your-backend.com

build-ios-dev:
	fvm flutter build ios -t lib/main_dev.dart --dart-define=BASE_URL=https://dev-api.your-backend.com

build-ios-prod:
	fvm flutter build ios -t lib/main_prod.dart --dart-define=BASE_URL=https://api.your-backend.com 