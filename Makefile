# Makefile for py-web-tool.
# Requires a pyweb-3.0.py (untouched) to bootstrap the current version.

SOURCE = pyweb.w intro.w overview.w impl.w tests.w additional.w todo.w done.w \
	test/pyweb_test.w test/intro.w test/unit.w test/func.w test/runner.w

.PHONY : test build

# Note the bootstrapping new version from version 3.0 as baseline.
# Handy to keep this *outside* the project's Git repository.
PYWEB_BOOTSTRAP=/Users/slott/Documents/Projects/PyWebTool-3/pyweb/pyweb.py

test : $(SOURCE)
	python3 $(PYWEB_BOOTSTRAP) -xw pyweb.w 
	cd test && python3 ../pyweb.py pyweb_test.w
	PYTHONPATH=${PWD} pytest
	cd test && rst2html.py pyweb_test.rst pyweb_test.html
	mypy --strict --show-error-codes pyweb.py

build : pyweb.py pyweb.html
     
pyweb.py pyweb.rst : $(SOURCE)
	python3 $(PYWEB_BOOTSTRAP) pyweb.w 

pyweb.html : pyweb.rst
	rst2html.py $< $@
