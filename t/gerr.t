#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

# Test module loading
BEGIN {
    use_ok('gerr');
}

# Test error function
{
    my $error_message = error("Test error message", "type=Test Error", "trace=2", "return=1");
    like($error_message, qr/Test error message/, "error() function test");
    like($error_message, qr/Test Error/, "error() type parameter test");
}

# Test trace function
{
    my $stack_trace = trace(3);
    like($stack_trace, qr/trace at/, "trace() function test");
}

done_testing();
