#!/usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile(NAME => "HTML::Diff",
	      VERSION => 0.55,
	      PREQREQ_PM => { 'Algorithm::Diff' => '1.15' },
	      INST_LIB => "./lib");
