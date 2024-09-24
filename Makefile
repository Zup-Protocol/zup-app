.PHONY: gen test


gen:
	@dart run build_runner build --delete-conflicting-outputs

test:
	@flutter test --coverage --test-randomize-ordering-seed=random && genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html