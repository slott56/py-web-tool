# Makefile for py-web-tool.
# Requires a stable, known good as the bootstrap to create a new version.

SOURCE_PYLPWEB = src/pyweb.w src/intro.w src/overview.w src/impl.w src/tests.w src/todo.w src/done.w src/language.w src/usage.w
TEST_PYLPWEB = tests/pyweb_test.w tests/intro.w tests/unit.w tests/func.w tests/scripts.w	
EXAMPLES_PYLPWEB = examples/hello_world_latex.w examples/hello_world_rst.w ackermanns.w
DOCUTILS_PYLPWEB = docutils.conf pyweb.css page-layout.css
TEST_DOCUTILS_PYLPWEB = tests/docutils.conf tests/pyweb.css tests/page-layout.css

.PHONY : test doc build examples tox

# Known good version.
PYLPWEB_BOOTSTRAP=${PWD}/bootstrap/pyweb.py

test : $(SOURCE_PYLPWEB) $(TEST_PYLPWEB)
	python3 $(PYLPWEB_BOOTSTRAP) -xw -v -o src src/pyweb.w 
	# cp src/pyweb.toml pyweb.toml  # Can obliterate test setup...
	python3 src/pyweb.py tests/pyweb_test.w -o tests
	PYTHONPATH=${PWD}/src PYTHONHASHSEED=0 pytest -vv
	python3 src/pyweb.py tests/pyweb_test.w -xt -o tests
	rst2html.py --config=tests/docutils.conf tests/pyweb_test.rst tests/pyweb_test.html
	pyright src

doc : src/pyweb.html

build : src/pyweb.py src/tangle.py src/weave.py src/pyweb.html tests/pyweb_test.rst

examples : examples/hello_world_latex.tex examples/hello_world_rst.html examples/ackermanns.html examples/hw.html

src/pyweb.py src/pyweb.rst : $(SOURCE_PYLPWEB)
	cd src && python3 pyweb.py pyweb.w 

src/pyweb.html : src/pyweb.rst $(DOCUTILS_PYLPWEB)
	# rst2html.py $< $@
	cd src && make html
         
tests/pyweb_test.rst tests/docutils.conf : src/pyweb.py $(TEST_PYLPWEB)
	python3 src/pyweb.py tests/pyweb_test.w -o tests

tests/pyweb_test.html : tests/pyweb_test.rst $(TEST_DOCUTILS_PYLPWEB)
	rst2html.py --config=tests/docutils.conf $< $@

examples/hello_world_rst.rst : examples/hello_world_rst.w
	python3 src/pyweb.py -w rst $< -o examples

examples/hello_world_rst.html : examples/hello_world_rst.rst $(DOCUTILS_PYLPWEB)
	rst2html.py $< $@

examples/hello_world_latex.tex : examples/hello_world_latex.w
	python3 src/pyweb.py -w latex $< -o examples

examples/ackermanns.rst : examples/ackermanns.w
	python3 src/pyweb.py -w rst $< -o examples
	python -m doctest examples/ackermanns.py

examples/ackermanns.html : examples/ackermanns.rst $(DOCUTILS_PYLPWEB)
	rst2html.py $< $@

examples/hw.rst : examples/hw.w
	python3 src/pyweb.py -pi -w rst $< -o examples
	python3 examples/hw.py >examples/hw_output.log

examples/hw.html : examples/hw.rst $(DOCUTILS_PYLPWEB)
	rst2html.py $< $@

tox:
	tox
