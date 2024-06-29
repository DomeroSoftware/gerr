#!/usr/bin/perl

use strict;
use warnings;
use utf8; # Enable UTF-8 support
use lib '../lib'; # Adjust the path as needed to locate gerr.pm
use gerr;

# Demonstration of the error function
eval {
    error("This is a fatal error message", "type=Example Error", "trace=1", "return=1");
};

if ($@) {
    print "Caught an error:\n";
    print $@;
}

# Demonstration of the trace function
sub example_subroutine {
    my $stack_trace = trace(3);
    print "Stack trace:\n$stack_trace";
}

example_subroutine();

1;
