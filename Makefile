.PHONY: gen test gen-l10n gen-routes

install:
	@flutter pub get && make gen

gen:
	@dart run build_runner build --delete-conflicting-outputs && make gen-l10n && make gen-routes && make gen-abis

gen-l10n:
	@flutter gen-l10n

gen-routes:
	@dart run routefly

gen-abis:
	@dart run web3kit:generate_abis

update-goldens:
	@flutter test --update-goldens

test:
	@flutter test --coverage --test-randomize-ordering-seed=random && genhtml coverage/lcov.info -o coverage/html && make open-coverage

open-coverage:
	@open coverage/html/index.html