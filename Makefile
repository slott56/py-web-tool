# Makefile for py-web-tool.
# Requires a stable, known good as the bootstrap to create a new version.

SOURCE_PYLPWEB = pyweb.w web/intro.w web/overview.w web/impl.w web/tests.w web/todo.w web/done.w web/language.w web/usage.w
TEST_PYLPWEB = pyweb_test.w web/test_intro.w web/unit.w web/functional.w web/test_scripts.w
EXAMPLES_PYLPWEB = examples/hello_world_latex.w examples/hello_world_rst.w ackermanns.w
DOCUTILS_PYLPWEB = docutils.conf pyweb.css page-layout.css
TEST_DOCUTILS_PYLPWEB = tests/docutils.conf tests/pyweb.css tests/page-layout.css

.PHONY : test doc build examples tox

# Known good version.
PYLPWEB_BOOTSTRAP=${PWD}/bootstrap/pyweb.py

test : $(SOURCE_PYLPWEB) $(TEST_PYLPWEB)
	# 1. Build new src/pyweb.py from pyweb.w -- NOTE pre 3.3 -o option.
	python3 $(PYLPWEB_BOOTSTRAP) -xw -v -t src -o docs pyweb.w
	# 2. Use new pyweb.py to build new tests/*.py from pyweb_test.w
	python3 src/pyweb.py pyweb_test.w -o docs
	# 3. Run test suite.
	PYTHONPATH=${PWD}/src PYTHONHASHSEED=0 pytest -vv
	# 4. Create documentation of test results.
	rst2html.py --config=docs/docutils.conf docs/pyweb_test.rst docs/pyweb_test.html
	# 5. Check type hints
	pyright src
	# 6. Linting.
	# ruff check src


build : bootstrap/pyweb.py src/pyweb.py src/tangle.py src/weave.py docs/pyweb.rst docs/pyweb_test.rst

src/pyweb.py docs/pyweb.rst : $(SOURCE_PYLPWEB)
	python3 src/pyweb.py pyweb.w -o docs -t src

doc : docs/pyweb.html docs/pyweb_test.html

docs/pyweb.html docs/pyweb_test.html : docs/index.rst docs/pyweb.rst docs/pyweb_test.rst
	# Docutils...
	# rst2html.py $< $@
	# SPHINX...
	cd docs && make html

docs/pyweb_test.rst : src/pyweb.py $(TEST_PYLPWEB)
	python3 src/pyweb.py pyweb_test.w -o docs

examples : examples/hello_world_latex.tex examples/hello_world_rst.html examples/ackermanns.html examples/hw.html

examples/hello_world_rst.rst : examples/hello_world_rst.w
	python3 src/pyweb.py -w rst $< -o examples

examples/hello_world_rst.html : examples/hello_world_rst.rst
	rst2html.py $< $@

examples/hello_world_latex.tex : examples/hello_world_latex.w
	python3 src/pyweb.py -w latex $< -o examples

examples/ackermanns.rst : examples/ackermanns.w
	python3 src/pyweb.py -w rst $< -o examples
	python -m doctest examples/ackermanns.py

examples/ackermanns.html : examples/ackermanns.rst
	rst2html.py $< $@

examples/hw.rst : examples/hw.w
	python3 src/pyweb.py -pi -w rst $< -o examples
	python3 examples/hw.py >examples/hw_output.log

examples/hw.html : examples/hw.rst
	rst2html.py $< $@

tox:
	tox run
