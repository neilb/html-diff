TEST_FILES = t/*.t

test:
	perl -MTest::Harness -e 'runtests @ARGV' $(TEST_FILES)
