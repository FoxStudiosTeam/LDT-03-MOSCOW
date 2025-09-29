-include .env
-include .env.local

run:
	flutter run --dart-define MAPKIT_API_KEY=$(MAP_KEY)
gen_install:
	npm install @openapitools/openapi-generator-cli -g
gen:
	npx openapi-generator-cli generate -g dart -i http://test.foxstudios.ru:8000/docs/merge -o ./lib/api --skip-validate-spec 
g:
	npx openapi-generator-cli generate -g dart -i https://test.foxstudios.ru:32460/api/project/openapi.json -o . --skip-validate-spec 