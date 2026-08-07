.PHONY: help clean get build run test format lint analyze coverage

help:
	@echo "License Manager - Android TV"
	@echo "Available commands:"
	@echo "  make clean         - Remove build artifacts"
	@echo "  make get           - Get Flutter dependencies"
	@echo "  make build         - Build release APK"
	@echo "  make bundle        - Build release App Bundle"
	@echo "  make run           - Run app on connected device"
	@echo "  make test          - Run tests"
	@echo "  make format        - Format Dart code"
	@echo "  make lint          - Run linter"
	@echo "  make analyze       - Analyze code"
	@echo "  make coverage      - Generate coverage report"

clean:
	flutter clean
	rm -rf build/
	rm -rf .dart_tool/

get:
	flutter pub get

build: get
	flutter build apk --release
	@echo "APK built: build/app/outputs/flutter-apk/app-release.apk"

bundle: get
	flutter build appbundle --release
	@echo "App Bundle built: build/app/outputs/bundle/release/app-release.aab"

run: get
	flutter run --release

test: get
	flutter test

format:
	dart format lib/ test/

lint: get
	flutter analyze

analyze: get lint
	dart pub outdated

coverage: test
	lcov --directory coverage --capture --output-file coverage/coverage.info

all: clean get analyze build
	@echo "Build complete!"
