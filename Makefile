# Makefile for py-web-tool.
# Requires a pyweb-3.0.py (untouched) to bootstrap the current version.

SOURCE_PYLPWEB = pyweb.w intro.w overview.w impl.w tests.w additional.w todo.w done.w
TEST_PYLPWEB = test/pyweb_test.w test/intro.w test/unit.w test/func.w test/runner.w	

.PHONY : test doc weave build

# Note the bootstrapping new version from version 3.0 as baseline.
# Handy to keep this *outside* the project's Git repository.
PYLPWEB_BOOTSTRAP=bootstrap/pyweb.py

test : $(SOURCE_PYLPWEB) $(TEST_PYLPWEB)
	python3 $(PYLPWEB_BOOTSTRAP) -xw pyweb.w 
	python3 pyweb.py test/pyweb_test.w -o test
	PYTHONPATH=${PWD} pytest
	rst2html.py test/pyweb_test.rst test/pyweb_test.html
	mypy --strict --show-error-codes pyweb.py tangle.py weave.py

weave : pyweb.py tangle.py weave.py

doc : pyweb.html

build : pyweb.py tangle.py weave.py pyweb.html

pyweb.py pyweb.rst : $(SOURCE_PYLPWEB)
	python3 $(PYLPWEB_BOOTSTRAP) pyweb.w 
         
pyweb.html : pyweb.rst
	rst2html.py $< $@
