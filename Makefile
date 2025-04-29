.PHONY: gen test gen-l10n gen-routes

install:
	@fvm flutter pub get && make gen

gen:
	@fvm dart run build_runner build --delete-conflicting-outputs && make gen-l10n && make gen-routes && make gen-abis

gen-l10n:
	@fvm flutter gen-l10n

gen-routes:
	@fvm dart run routefly

gen-abis:
	@fvm dart run web3kit:generate_abis

update-goldens:
	@fvm flutter test --update-goldens

test:
	@fvm flutter test --coverage --test-randomize-ordering-seed=random && genhtml coverage/lcov.info -o coverage/html && make open-coverage

open-coverage:
	@open coverage/html/index.html