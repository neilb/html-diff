#!/usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'HTML::Diff',
    VERSION_FROM => 'lib/HTML/Diff.pm',

    PREREQ_PM    => {
        'Algorithm::Diff'   => '1.15',
        'warnings'          => 0,
        'strict'            => 0,
        'Exporter'          => 0,
    },

    EXE_FILES    => ['htmldiff'],
);

