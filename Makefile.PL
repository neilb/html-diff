#!/usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile(NAME => "HTML::Diff",
	      VERSION => 0.561,
	      PREREQ_PM => { 'Algorithm::Diff' => '1.15' },
	      INST_LIB => "./lib",
	      EXE_FILES => ["htmldiff"]);
