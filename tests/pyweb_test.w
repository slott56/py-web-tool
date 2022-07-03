############################################
pyWeb Literate Programming 3.2 - Test Suite
############################################    
    
    
=================================================
Yet Another Literate Programming Tool
=================================================

..	contents::


@i intro.w

@i unit.w

@i func.w

@i scripts.w

No Longer supported: @@i runner.w, using **pytest** seems better.

Additional Files
=================

To get the RST to look good, there are two additional files.
These are clones of what's in the ``src`` directory.

``docutils.conf`` defines two CSS files to use.
	The default CSS file may need to be customized.

@o docutils.conf 
@{# docutils.conf

[html4css1 writer]
stylesheet-path: /Users/slott/miniconda3/envs/pywebtool/lib/python3.10/site-packages/docutils/writers/html4css1/html4css1.css,
    page-layout.css
syntax-highlight: long
@}

``page-layout.css``  This tweaks one CSS to be sure that
the resulting HTML pages are easier to read. These are minor
tweaks to the default CSS.

@o page-layout.css 
@{/* Page layout tweaks */
div.document { width: 7in; }
.small { font-size: smaller; }
.code
{
	color: #101080;
	display: block;
	border-color: black;
	border-width: thin;
	border-style: solid;
	background-color: #E0FFFF;
	/*#99FFFF*/
	padding: 0 0 0 1%;
	margin: 0 6% 0 6%;
	text-align: left;
	font-size: smaller;
}
@}


Indices
=======

Files
-----

@f

Macros
------

@m


----------

..	class:: small

	Created by @(thisApplication@) at @(datetime.datetime.now().ctime()@).

    Source @(theFile@) modified @(datetime.datetime.fromtimestamp(os.path.getmtime(theFile)).ctime()@).

	pyweb.__version__ '@(__version__@)'.

	Working directory '@(os.path.realpath('.')@)'.
