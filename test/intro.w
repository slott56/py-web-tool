<!-- test/intro.w -->

<p>There are two levels of testing in this document.</p>
<ul>
<li><a href="#unit">Unit</a></li>
<li><a href="#functional">Functional</a></li>
</ul>

<p>Other testing, like performance or security, is possible.
But for this application, not very interesting.
</p>

<p>This doument builds a complete test suite, <span class="code">test.py</span>.

<pre>
MacBook-6:pyweb slott$ cd test
MacBook-6:test slott$ export PYTHONPATH=..
MacBook-6:test slott$ python -m pyweb pyweb_test.w
INFO:pyweb:Reading 'pyweb_test.w'
INFO:pyweb:Starting Load [WebReader, Web 'pyweb_test.w']
INFO:pyweb:Including 'intro.w'
INFO:pyweb:Including 'unit.w'
INFO:pyweb:Including 'func.w'
INFO:pyweb:Including 'combined.w'
INFO:pyweb:Starting Tangle [Web 'pyweb_test.w']
INFO:pyweb:Tangling 'test_unit.py'
INFO:pyweb:No change to 'test_unit.py'
INFO:pyweb:Tangling 'test_weaver.py'
INFO:pyweb:No change to 'test_weaver.py'
INFO:pyweb:Tangling 'test_tangler.py'
INFO:pyweb:No change to 'test_tangler.py'
INFO:pyweb:Tangling 'test.py'
INFO:pyweb:No change to 'test.py'
INFO:pyweb:Tangling 'test_loader.py'
INFO:pyweb:No change to 'test_loader.py'
INFO:pyweb:Starting Weave [Web 'pyweb_test.w', None]
INFO:pyweb:Weaving 'pyweb_test.html'
INFO:pyweb:Wrote 2519 lines to 'pyweb_test.html'
INFO:pyweb:pyWeb: Load 1695 lines from 5 files in 0 sec., Tangle 80 lines in 0.1 sec., Weave 2519 lines in 0.0 sec.
MacBook-6:test slott$ python test.py
.......................................................................
----------------------------------------------------------------------
Ran 71 tests in 2.043s

OK
MacBook-6:test slott$ 
</pre>