# Makefile for py-web-tool.
# Requires a pyweb-3.0.py (untouched) to bootstrap the current version.

SOURCE_PYLPWEB = src/pyweb.w src/intro.w src/overview.w src/impl.w src/tests.w src/todo.w src/done.w
TEST_PYLPWEB = tests/pyweb_test.w tests/intro.w tests/unit.w tests/func.w tests/scripts.w	

.PHONY : test doc build

# Note the bootstrapping new version from version 3.0 as baseline.
# Handy to keep this *outside* the project's Git repository.
# Note that the bootstrap 3.0 version doesn't support the -o option.
PYLPWEB_BOOTSTRAP=${PWD}/bootstrap/pyweb.py

test : $(SOURCE_PYLPWEB) $(TEST_PYLPWEB)
	cd src && python3 $(PYLPWEB_BOOTSTRAP) -xw pyweb.w 
	python3 src/pyweb.py tests/pyweb_test.w -o tests
	PYTHONPATH=${PWD}/src pytest
	python3 src/pyweb.py tests/pyweb_test.w -xt -o tests
	rst2html.py tests/pyweb_test.rst tests/pyweb_test.html
	mypy --strict --show-error-codes src

doc : src/pyweb.html

build : src/pyweb.py src/tangle.py src/weave.py src/pyweb.html

src/pyweb.py src/pyweb.rst : $(SOURCE_PYLPWEB)
	cd src && python3 $(PYLPWEB_BOOTSTRAP) pyweb.w 
         
tests/pyweb_test.rst : src/pyweb.py $(TEST_PYLPWEB)
	python3 pyweb.py tests/pyweb_test.w -o tests

src/pyweb.html : src/pyweb.rst docutils.conf pyweb.css page-layout.css
	rst2html.py $< $@

tests/pyweb_test.html : tests/pyweb_test.rst docutils.conf pyweb.css page-layout.css
	rst2html.py $< $@
