<!-- pyweb/additional.w -->

<p>Here are some additional support components.</p>

<h2>JEdit Configuration</h2>
<p>Here's the <tt>pyweb.xml</tt> file that you'll  need to configure
JEdit so that it properly highlights your PyWeb commands.
</p>

<p>We'll define the overall properties plus two sets of rules.</p>
@o jedit/pyweb.xml @{<?xml version="1.0"?>
<!DOCTYPE MODE SYSTEM "xmode.dtd">

<MODE>
    @<props for JEdit mode@>
    @<rules for JEdit PyWeb and RST@>
    @<rules for JEdit PyWeb XML-Like Constructs@>
</MODE>
@}

<p>Here are some properties to define RST constructs to JEdit</p>
@d props for JEdit mode
@{
<PROPS>
    <PROPERTY NAME="lineComment" VALUE=".. "/>
    <!-- indent after literal blocks and directives -->
    <PROPERTY NAME="indentNextLines" VALUE=".*::$"/>
    <!--
    <PROPERTY NAME="commentStart" VALUE="@@{" />
    <PROPERTY NAME="commentEnd" VALUE="@@}" />
    -->
</PROPS>
@}

<p>Here are some rules to define PyWeb and RST constructs to JEdit.</p>

@d rules for JEdit PyWeb and RST
@{
<RULES IGNORE_CASE="FALSE" HIGHLIGHT_DIGITS="FALSE">

    <!-- targets -->
    <EOL_SPAN AT_LINE_START="TRUE" TYPE="KEYWORD3">__</EOL_SPAN>
    <EOL_SPAN AT_LINE_START="TRUE" TYPE="KEYWORD3">.. _</EOL_SPAN>

    <!-- section titles -->
    <SEQ_REGEXP HASH_CHAR="===" TYPE="LABEL">={3,}</SEQ_REGEXP>
    <SEQ_REGEXP HASH_CHAR="---" TYPE="LABEL">-{3,}</SEQ_REGEXP>
    <SEQ_REGEXP HASH_CHAR="~~~" TYPE="LABEL">~{3,}</SEQ_REGEXP>
    <SEQ_REGEXP HASH_CHAR="###" TYPE="LABEL">#{3,}</SEQ_REGEXP>
    <SEQ_REGEXP HASH_CHAR='"""' TYPE="LABEL">"{3,}</SEQ_REGEXP>
    <SEQ_REGEXP HASH_CHAR="^^^" TYPE="LABEL">\^{3,}</SEQ_REGEXP>
    <SEQ_REGEXP HASH_CHAR="+++" TYPE="LABEL">\+{3,}</SEQ_REGEXP>
    <SEQ_REGEXP HASH_CHAR="***" TYPE="LABEL">\*{3,}</SEQ_REGEXP>

    <!-- replacement -->
    <SEQ_REGEXP
        HASH_CHAR=".."
        AT_LINE_START="TRUE"
        TYPE="LITERAL3"
    >\.\.\s\|[^|]+\|</SEQ_REGEXP>

    <!-- substitution -->
    <SEQ_REGEXP
        HASH_CHAR="|"
        AT_LINE_START="FALSE"
        TYPE="LITERAL4"
    >\|[^|]+\|</SEQ_REGEXP>

    <!-- directives: .. name:: -->
    <SEQ_REGEXP
        HASH_CHAR=".."
        AT_LINE_START="TRUE"
        TYPE="LITERAL2"
    >\.\.\s[A-z][A-z0-9-_]+::</SEQ_REGEXP>

    <!-- strong emphasis: **...** -->
    <SEQ_REGEXP
        HASH_CHAR="**"
        AT_LINE_START="FALSE"
        TYPE="KEYWORD2"
    >\*\*[^*]+\*\*</SEQ_REGEXP>

    <!-- emphasis: *...* -->
    <SEQ_REGEXP
        HASH_CHAR="*"
        AT_LINE_START="FALSE"
        TYPE="KEYWORD4"
    >\*[^\s*][^*]*\*</SEQ_REGEXP>

    <!-- comments -->
    <EOL_SPAN AT_LINE_START="TRUE" TYPE="COMMENT1">.. </EOL_SPAN>

    <!-- links: `...`_ or `...`__ -->
    <SEQ_REGEXP
        HASH_CHAR="`"
        TYPE="LABEL"
    >`[A-z0-9]+[^`]+`_{1,2}</SEQ_REGEXP>

    <!-- footnote reference: [0]_ -->
    <SEQ_REGEXP
        HASH_CHAR="["
        TYPE="LABEL"
    >\[[0-9]+\]_</SEQ_REGEXP>

    <!-- footnote reference: [#]_ or [#foo]_ -->
    <SEQ_REGEXP
        HASH_CHAR="[#"
        TYPE="LABEL"
    >\[#[A-z0-9_]*\]_</SEQ_REGEXP>

    <!-- footnote reference: [*]_ -->
    <SEQ TYPE="LABEL">[*]_</SEQ>

    <!-- citation reference: [foo]_ -->
    <SEQ_REGEXP
        HASH_CHAR="["
        TYPE="LABEL"
    >\[[A-z][A-z0-9_-]*\]_</SEQ_REGEXP>

    <!-- inline literal: ``...``-->
    <!--<SEQ_REGEXP
        HASH_CHAR="``"
        TYPE="LITERAL1"
    >``[^`]+``</SEQ_REGEXP>-->
    <SPAN TYPE="LITERAL1" ESCAPE="\">
        <BEGIN>``</BEGIN>
        <END>``</END>
    </SPAN>

    <!-- interpreted text: `...` -->
    <!--
    <SEQ_REGEXP
        HASH_CHAR="`"
        TYPE="KEYWORD1"
    >`[^`]+`</SEQ_REGEXP>
    
    -->
    <EOL_SPAN TYPE="COMMENT1">@@d</EOL_SPAN>
    <EOL_SPAN TYPE="COMMENT1">@@o</EOL_SPAN>

    <SPAN TYPE="COMMENT1" DELEGATE="CODE">
        <BEGIN>@@{</BEGIN>
        <END>@@}</END>
    </SPAN>

    <SPAN TYPE="KEYWORD1">
        <BEGIN>`</BEGIN>
        <END>`</END>
    </SPAN>

    <SEQ_REGEXP HASH_CHAR="```" TYPE="LABEL">`{3,}</SEQ_REGEXP>

    <!-- :field list: -->
    <SEQ_REGEXP
        HASH_CHAR=":"
        TYPE="KEYWORD1"
    >:[A-z][A-z0-9 	=\s\t_]*:</SEQ_REGEXP>

    <!-- table -->
    <SEQ_REGEXP
        HASH_CHAR="+-"
        TYPE="LABEL"
    >\+-[+-]+</SEQ_REGEXP>
    <SEQ_REGEXP
        HASH_CHAR="+?"
        TYPE="LABEL"
    >\+=[+=]+</SEQ_REGEXP>

</RULES>
@}

<p>Here are some additional rules to define PyWeb constructs to JEdit
that look like XML.</p>

@d rules for JEdit PyWeb XML...
@{
<RULES SET="CODE" DEFAULT="KEYWORD1">
    <SPAN TYPE="MARKUP">
        <BEGIN>@@&lt;</BEGIN>
        <END>@@&gt;</END>
    </SPAN>
</RULES>
@}

<p>Additionally, you'll want to update the JEdit catalog.</p>
<code><pre>
&lt;?xml version="1.0"?&gt;
&lt;!DOCTYPE MODES SYSTEM "catalog.dtd"&gt;
&lt;MODES&gt;

&lt;!-- Add lines like the following, one for each edit mode you add: --&gt;
&lt;MODE NAME="pyweb" FILE="pyweb.xml" FILE_NAME_GLOB="*.w" /&gt;

&lt;/MODES&gt;
</pre></code>