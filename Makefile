# Makefile for py-web-tool.
# Requires a pyweb-3.0.py (untouched) to bootstrap the current version.

SOURCE = pyweb.w intro.w overview.w impl.w tests.w additional.w todo.w done.w \
	test/pyweb_test.w test/intro.w test/unit.w test/func.w test/combined.w

.PHONY : test build

# Note the bootstrapping new version from version 3.0 as baseline.

test : $(SOURCE)
	python3 pyweb-3.0.py -xw pyweb.w 
	cd test && python3 ../pyweb.py pyweb_test.w
	cd test && PYTHONPATH=.. python3 test.py
	cd test && rst2html.py pyweb_test.rst pyweb_test.html
	mypy --strict pyweb.py

build : pyweb.py pyweb.html
     
pyweb.py pyweb.html : $(SOURCE)
	python3 pyweb-3.0.py pyweb.w 

