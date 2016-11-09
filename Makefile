HTML := $(shell find bower_components components -name \*.html -print)
JS := $(shell find bower_components components -name \*.js -print)
SCSS := $(shell find css -name \*.scss -print)

build: index.html index.js

index.html: bower_components components app.html css/main.css $(JS) $(HTML)
	vulcanize --abspath . --strip-comments --inline-scripts --inline-css app.html | crisper --html index.html --js index.js
	html-minifier --collapse-whitespace --conservative-collapse --html5 --minify-css true --remove-comments --remove-tag-whitespace index.html -o index.html

index.js: index.html
	babel index.js > /tmp/index.js
	uglifyjs -cm -- /tmp/index.js > index.js

css/main.css: $(SCSS)
	sass css/main.scss:css/main.css

deps:
	npm install
	bower install
	gem install sass
	sudo npm install -g vulcanize uglify-js html-minifier

watch:
	while true; do \
		make build; \
		inotifywait -qre close_write .; \
	done

clean:
	rm -f index.html index.js

.PHONY: build deps watch clean
