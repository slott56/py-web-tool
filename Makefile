# Makefile for py-web-tool.
# Requires a pyweb-3.0.py (untouched) to bootstrap the current version.

SOURCE_PYLPWEB = pyweb.w intro.w overview.w impl.w tests.w additional.w todo.w done.w
TEST_PYLPWEB = tests/pyweb_test.w tests/intro.w tests/unit.w tests/func.w tests/scripts.w	

.PHONY : test doc build

# Note the bootstrapping new version from version 3.0 as baseline.
# Handy to keep this *outside* the project's Git repository.
PYLPWEB_BOOTSTRAP=bootstrap/pyweb.py

test : $(SOURCE_PYLPWEB) $(TEST_PYLPWEB)
	python3 $(PYLPWEB_BOOTSTRAP) -xw pyweb.w 
	python3 pyweb.py tests/pyweb_test.w -o tests
	PYTHONPATH=${PWD} pytest
	python3 pyweb.py tests/pyweb_test.w -xt -o tests
	rst2html.py tests/pyweb_test.rst tests/pyweb_test.html
	mypy --strict --show-error-codes pyweb.py tangle.py weave.py

doc : pyweb.html

build : pyweb.py tangle.py weave.py pyweb.html

pyweb.py pyweb.rst : $(SOURCE_PYLPWEB)
	python3 $(PYLPWEB_BOOTSTRAP) pyweb.w 
         
tests/pyweb_test.rst : pyweb.py $(TEST_PYLPWEB)
	python3 pyweb.py tests/pyweb_test.w -o tests

pyweb.html : pyweb.rst
	rst2html.py $< $@

tests/pyweb_test.html : tests/pyweb_test.rst
	rst2html.py $< $@

