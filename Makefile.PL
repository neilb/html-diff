#!/usr/bin/perl

use ExtUtils::MakeMaker;

my $mm_ver = $ExtUtils::MakeMaker::VERSION;
if ($mm_ver =~ /_/) {
    $mm_ver = eval $mm_ver;
    die $@ if $@;
}

WriteMakefile(
    NAME         => 'HTML::Diff',
    VERSION_FROM => 'lib/HTML/Diff.pm',

    PREREQ_PM    => {
        'Algorithm::Diff'   => '1.15',
        'warnings'          => 0,
        'strict'            => 0,
        'Exporter'          => 0,
    },

    ($mm_ver >= 6.31
        ? (LICENSE => 'perl')
        : ()
    ),

    EXE_FILES    => ['htmldiff'],
);

