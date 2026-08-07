FROM cirrusci/android-flutter:latest

WORKDIR /app

COPY . .

RUN flutter pub get

RUN flutter build apk --release

FROM scratch
COPY --from=0 /app/build/app/outputs/flutter-apk/app-release.apk /app-release.apk
