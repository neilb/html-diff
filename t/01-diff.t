#!/usr/bin/perl

use strict;

use Test;

BEGIN { plan tests => 4 }

use Getopt::Long;
my ($verbose);
GetOptions("verbose!" => \$verbose) or die "Parsing command line failed.";

use Data::Dumper;

my $html_diff_root = $ENV{PWD};
while (!-r "$html_diff_root/HTML/Diff.pm")
{
    ($html_diff_root) = $html_diff_root =~ m#(/(?:[^/]*/)*?)[^/]+/*$#;
}

die "Couldn't find HTML::Diff" 
    unless -r "$html_diff_root/HTML/Diff.pm";

use lib "$html_diff_root/HTML/Diff.pm";
use HTML::Diff qw(line_diff word_diff html_word_diff);

my $test_text_a = "Four score
and seven years ago, our forefathers 
brought forth on this continent
a new nation conceived 
in liberty and
dedicated to the proposition
that all men are created equal.
Now our great nation is
engaged in civil war.";

my $test_text_b = "Four score
and seven years ago, our forefathers 
brought forth on this continent
dedicated to the proposition
that all men are created equal.
Now our great nation is enagaged
in civil war";

my $test_text_c = 'PEOPLE said, "The evening-bell is sounding, the sun is setting." A strange wondrous tone was heard in the narrow streets of a large town. It was like the sound of a church-bell: but it was only heard for a moment, for the rolling of the carriages, and the voices of the multitude made too great a noise.';

my $test_text_d = 'PEOPLE said, "The bell is sounding." A strange wondrous was heard tone in the narrow streets of a large town. A long time passed. It was like the sound of a church-bell: but it was only heard for a moment, for the rolling of the carriages, and the voices of the multitude made too great a noise.';

# This next pair tests the usual HTML changes 
# (e.g. "<b>a b c d</b>" -> "<i>a b c d</i>" considers all of "a b c d" 
# as a change). It also tests that whitespace changes are effectively ignored.

my $test_html_a = '<center>
<h1>
<a href="http://www.cs.brown.edu/people/jes/acm.strategic.dirs.html">Strategic Directions for <b> Research in Theory of Computing </b></a>
</h1>

September 23, 1996
</center>

<p>

Anne Condon, University of Wisconsin <br>
Faith Fich, University of Toronto <br>
Greg N. Frederickson, Purdue University <br>
Andrew V. Goldberg, NEC Research Institute <br>
David S. Johnson, AT&amp;T Bell Laboratories <br>
Michael C. Loui, University of Illinois at Urbana-Champaign  <br>
Steven Mahaney, DIMACS <P>

Prabhakar Raghavan, IBM Almaden Research Center <br>
John Savage, Brown University <br>
Alan Selman, SUNY at Buffalo <br>
David B. Shmoys, Cornell University 
<p>

<strong>Abstract.</strong>
This report focuses on two core areas of theory of computing:
discrete algorithms and computational complexity theory.
The report 
reviews the purposes and goals of theoretical research,
summarizes selected past and recent achievements,
<i>explains the importance of</i> sustaining core research,
and identifies promising opportunities for future research.
Some research opportunities build bridges between
theory of computing and other areas of computer science,
and other science and engineering disciplines.
<p>';

my $test_html_b = '<center>
<h1>
<a href="http://www.google.com/">Strategic Directions for <i> Research in Theory of Computing </i></a>
</h1>

September 23, 1996
</center>

<p>

Anne Condon, University of Wisconsin <br>
Faith Fich, University of Toronto <br>
Greg N. Frederickson, Purdue University <br>
Andrew V. Goldberg, NEC Research Institute <br>
David S. Johnson, AT&amp;T Bell Laboratories <br>
Michael C. Loui, University of Illinois at Urbana-Champaign  <br>
Steven Mahaney, DIMACS <br>

Prabhakar Raghavan, IBM Almaden Research Center <br>
John Savage, Brown University <br>
Alan Selman, SUNY at Buffalo <br>
David B. Shmoys, Cornell University 
<p>

<strong>Abstract.</strong> This report focuses on two core areas of
theory of computing: discrete algorithms and computational complexity
theory.  The report reviews the purposes and goals of theoretical
research, summarizes selected past and recent achievements, explains
the importance of sustaining core research, and identifies promising
opportunities for future research.  Some research opportunities build
bridges between theory of computing and other areas of computer
science, and other science and engineering disciplines.  <p>';

sub print_diff {
    my $ch;
    my ($chunks) = @_;
    foreach $ch (@$chunks) {
	my ($flag, $m, $o) = @$ch;
	unless ($flag eq 'u') {
	    print "<< old\n";
	    print "$o";
	    print ">> new\n";
	    print "$m";
	    print "==\n";
	    # TBD: make some kind of warning about lacking a newline at the end
	} else {
	    print "$m";
	}
    }
}

sub test_diff_continuity {
    my ($a, $b, $diffalgo, $ignore_whitespace) = @_;
    my $chunks = &$diffalgo($a, $b);
    my ($runningb, $runninga);
    $runninga = $runningb = "";
    my $ch;
    foreach $ch (@$chunks)
    {
	my ($flag, $ach, $bch) = @$ch;
	$runninga .= $ach || '';
	$runningb .= $bch || '';
    }
    if ($ignore_whitespace) {
	$a =~ s/\s\s+/ /g;
	$b =~ s/\s\s+/ /g;
	$runninga =~ s/\s\s+/ /g;
	$runningb =~ s/\s\s+/ /g;
    }
    return ($a eq $runninga) && ($b eq $runningb);
}

sub expect_diff {
    my ($a, $b, $algo, $expectation) = @_;
}

if ($verbose) {
    my $chunks = HTML::Diff::line_diff($test_text_a, $test_text_b);
    print_diff($chunks);
    $chunks = HTML::Diff::word_diff($test_text_c, $test_text_d);
    print "\n";
    print_diff($chunks);
}
print "Testing line_diff on test_text_a and test_text_b\n" if $verbose;
ok(test_diff_continuity($test_text_a, $test_text_b, 
			\&HTML::Diff::line_diff));
print "Testing html_word_diff on test_text_a and test_text_b\n"
    if $verbose;
ok(test_diff_continuity($test_text_a, $test_text_b, 
			\&HTML::Diff::html_word_diff));
print "Testing html_word_diff on test_html_a and test_html_b\n" 
    if $verbose;
ok(test_diff_continuity($test_html_a, $test_html_b, 
			\&HTML::Diff::html_word_diff, 1));
my $result = HTML::Diff::html_word_diff($test_html_a, $test_html_b);

#open OUT, ">expect";
#print OUT Dumper($result);
#close OUT;

my $expect = [
    [
     undef,
     undef,
     undef
    ],
    [
     'u',
     '<center>
<h1>
',
     '<center>
<h1>
'
    ],
    [
     'c',
     '<a href="http://www.cs.brown.edu/people/jes/acm.strategic.dirs.html">',
     '<a href="http://www.google.com/">'
    ],
    [
     'u',
     'Strategic Directions for ',
     'Strategic Directions for '
    ],
    [
     'c',
     '<b> Research in Theory of Computing </b>',
     '<i> Research in Theory of Computing </i>'
    ],
    [
     'u',
     '</a>
</h1>

September 23, 1996
</center>

<p>

Anne Condon, University of Wisconsin <br>
Faith Fich, University of Toronto <br>
Greg N. Frederickson, Purdue University <br>
Andrew V. Goldberg, NEC Research Institute <br>
David S. Johnson, AT&amp;T Bell Laboratories <br>
Michael C. Loui, University of Illinois at Urbana-Champaign  <br>
Steven Mahaney, DIMACS ',
            '</a>
</h1>

September 23, 1996
</center>

<p>

Anne Condon, University of Wisconsin <br>
Faith Fich, University of Toronto <br>
Greg N. Frederickson, Purdue University <br>
Andrew V. Goldberg, NEC Research Institute <br>
David S. Johnson, AT&amp;T Bell Laboratories <br>
Michael C. Loui, University of Illinois at Urbana-Champaign  <br>
Steven Mahaney, DIMACS '
    ],
    [
     'c',
     '<P>

',
     '<br>

'
    ],
    [
     'u',
     'Prabhakar Raghavan, IBM Almaden Research Center <br>
John Savage, Brown University <br>
Alan Selman, SUNY at Buffalo <br>
David B. Shmoys, Cornell University 
<p>

<strong>Abstract.</strong>
This report focuses on two core areas of theory of computing:
discrete algorithms and computational complexity theory.
The report 
reviews the purposes and goals of theoretical research,
summarizes selected past and recent achievements,
',
     'Prabhakar Raghavan, IBM Almaden Research Center <br>
John Savage, Brown University <br>
Alan Selman, SUNY at Buffalo <br>
David B. Shmoys, Cornell University 
<p>

<strong>Abstract.</strong> This report focuses on two core areas of
theory of computing: discrete algorithms and computational complexity
theory.  The report reviews the purposes and goals of theoretical
research, summarizes selected past and recent achievements, '
    ],
    [
     '-',
     '<i>explains the importance of</i> ',
     'explains
the importance of '
    ],
    [
     'u',
     'sustaining core research,
and identifies promising opportunities for future research.
Some research opportunities build bridges between
theory of computing and other areas of computer science,
and other science and engineering disciplines.
<p>',
     'sustaining core research, and identifies promising
opportunities for future research.  Some research opportunities build
bridges between theory of computing and other areas of computer
science, and other science and engineering disciplines.  <p>'
    ]
];

ok(deep_compare($result, $expect));

# Given two array refs of array refs, of array refs...  return true if
# the two structures are isomorphic and all the corresponding scalars
# are equal
# TBD: make it more efficient; builds up call stack too much.
# TBD: Take a binary test as an arg, to replace eq
sub deep_compare {
    my ($a, $b) = @_;
    my ($x, $y);
    if (!ref($a) && !ref($b)) {
	return $a eq $b;
    } else {
	return 0 unless ((ref($a) eq 'ARRAY') && (ref($b) eq 'ARRAY'));
	while ($x = shift @$a) {
	    $y = shift @$b;
	    return 0 unless deep_compare($x, $y);
	}
    }
    return 1;
}

my $diffchunks = HTML::Diff::html_word_diff($test_html_a, $test_html_b);
if ($verbose) {
    print "Result of diff:\n";
    print "[$_]\n" foreach (map {join "||", @$_} @$diffchunks);
}

sub diff_file {
    my ($left, $right) = @_;
    open LEFT, $left;
    open RIGHT, $right;
    $/ = undef;
    my $Left = <LEFT>;
    my $Right = <RIGHT>;
    close LEFT;
    close RIGHT;
    my $diff_chunks = html_word_diff($Left, $Right);
    print_diff($diff_chunks);
    print "\n";
}

1;
