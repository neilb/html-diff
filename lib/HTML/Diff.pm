#!/usr/bin/perl

package HTML::Diff;

$VERSION = '0.5';

use strict;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(line_diff word_diff html_word_diff);

our $UNBALANCED_TAGS = qr/br|hr|^p$|li|\/>$/i;

use Algorithm::Diff 'sdiff';

sub html_word_diff {
    my ($left, $right) = @_;

    # Split the two texts into words and tags.
    my (@leftchks) = $left =~ m/(<[^>]*>\s*|[^<]+)/gm;
    my (@rightchks) = $right =~ m/(<[^>]*>\s*|[^<]+)/gm;
    
    @leftchks = map { $_ =~ /^<[^>]*>$/ ? $_ : ($_ =~ m/(\S+\s*)/gm) }
                    @leftchks;
    @rightchks = map { $_ =~ /^<[^>]*>$/ ? $_ : ($_ =~ m/(\S+\s*)/gm) } 
                     @rightchks;

    # Remove blanks; maybe the above regexes could handle this?
    @leftchks = grep { $_ ne '' } @leftchks;
    @rightchks = grep { $_ ne '' } @rightchks;

    # Now we process each segment by turning it into a pair. The first element
    # is the text as we want it to read in the result. The second element is
    # the value we will to use in comparisons. It contains an identifier
    # for each of the balanced tags that it lies within.

    # This subroutine holds state in the tagstack variable
    my $tagstack = [];
    my $smear_tags = sub {
	if ($_ =~ /^<.*>/) {
	    if ($_ =~ m|^</|) {
		my ($tag) = m|^</\s*([^ \t\n\r>]*)|;
		# If we found the closer for the tag on top 
		# of the stack, pop it off.
		if ($$tagstack[-1] eq $tag) {
                    my $stacktag = pop @$tagstack;
                }
		return [$_, $tag];
	    } else {
		my ($tag) = m|^<\s*([^ \t\n\r>]*)|;
		if ($tag =~ $UNBALANCED_TAGS)
		{	                        # (tags without closers)
		    return [$_, $tag];
		} else {
		    push @$tagstack, $tag;
		}
		return [$_, $_];
	    }
	} else {
	    my $result = [$_, (join "!!!", (@$tagstack, $_)) ];
	    return $result;
	}
    };

    # Now do the "smear tags" operation across each of the chunk-lists
    $tagstack = [];
    @leftchks = map { &$smear_tags } @leftchks;
    # TBD: better modularity would preclude having to reset the stack
    $tagstack = [];
    @rightchks = map { &$smear_tags } @rightchks;

    # Now do the diff, using the "comparison" half of the pair to
    # compare two chuncks.
    my $chunks = sdiff(\@leftchks, \@rightchks,
		      sub { $_ = elem_cmprsn(shift); $_ =~ s/\s+$/ /g; $_ });

    # Finally, process the output of sdiff by concatenating
    # consecutive chunks that were "unchanged."
    my $lastsignal = '';
    my ($lbuf, $rbuf);
    my @result;
    my $ch;
    foreach $ch (@$chunks) {
	my ($signal, $left, $right) = @$ch;
	if ($signal eq 'u' && $lastsignal ne 'u') {
	    push @result, [$lastsignal, $lbuf, $rbuf];
	    $lbuf = "";
	    $rbuf = "";
	} elsif ($signal ne 'u' && $lastsignal eq 'u') {
	    push @result, [$lastsignal, $lbuf, $rbuf];
	    $lbuf = "";
	    $rbuf = "";
	}
	$lbuf .= elem_mkp($left) || '';
	$rbuf .= elem_mkp($right) || '';
	$lastsignal = $signal;
    }
    push @result, [$lastsignal, $lbuf, $rbuf];
    return \@result;
}

# these are like "accessors" for the two halves of the diff-chunk pairs
sub elem_mkp {
    my ($e) = @_;
    return undef unless ref $e eq 'ARRAY';
    my ($mkp, $cmp) = @$e;
    return $mkp;
}

sub elem_cmprsn {
    my ($e) = @_;
    return undef unless ref $e eq 'ARRAY';
    my ($mkp, $cmp) = @$e;
    return $cmp;
}

# Finally a couple of non-HTML diff routines

sub line_diff {
    my ($left, $right) = @_;
    my (@leftchks) = $left =~ m/(.*\n?)/gm;
    my (@rightchks) = $right =~ m/(.*\n?)/gm;
    my $result = sdiff(\@leftchks, \@rightchks);
#    my @result = map { [ $_->[1], $_->[2] ] } @$result;
    return $result;
}

sub word_diff {
    my ($left, $right) = @_;
    my (@leftchks) = $left =~ m/([^\s]*\s?)/gm;
    my (@rightchks) = $right =~ m/([^\s]*\s?)/gm;

    my $result = sdiff(\@leftchks, \@rightchks);
    my @result = (map { [ $_->[1], $_->[2] ] } @$result);
    return $result;
}

1;

=pod

=head1 HTML::Diff

This module compares two strings of HTML and returns a list of a chunks
which indicate the diff between the two input strings, where changes
in formatting are considered changes.

=head1 SYNOPSIS

 $result = html_word_diff($left_text, $right_text);

=head1 DESCRIPTION

   Returns a reference to a list of triples [<flag>, <left>, <right>].
   Concatenating all the <left> members from the return value should
   produce the input $left_text, and likewise for the <right> members.

   The <flag> is either 'u', '+', '-', or 'c', indicating whether the
   two chunks are the same, the $right_text contained this chunk and 
   the left chunk didn't, or vice versa, or the two chunks are simply
   different. This follows the usage of Algorithm::Diff.

   The difference is computed on a word-by-word basis, "breaking" on
   visible words in the HTML text. If a tag only is changed, it will
   not be returned as an independent chunk but will be shown as a
   change to one of the neighboring words. For balanced tags, such as
   <b> </b>, it is intended that a change to the tag will be treated
   as a change to all words in between.

=head1 AUTHOR

   Whipped up by Ezra elias kilty Cooper, ezra@ezrakilty.net

=head1 SEE ALSO

   Algorithm::Diff

=cut
