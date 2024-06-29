#!/usr/bin/perl

=head1 NAME

gerr - Eureka Error System v1.1.2

=head1 SYNOPSIS

    use gerr;
    my $error_message = error("error message");

=head1 DESCRIPTION

This module provides functions for generating formatted error messages and stack traces.

=head1 VERSION

Version 1.13

=cut

#############################################################################
#                                                                           #
#   Eureka Error System v1.1.2                                              #
#   (C) 2020 Domero, Groningen, NL                                          #
#   ALL RIGHTS RESERVED                                                     #
#                                                                           #
#############################################################################

package gerr;

use strict;
use warnings;
use Exporter;

our $VERSION = '1.13';
our @ISA = qw(Exporter);
our @EXPORT = qw(error);
our @EXPORT_OK = qw(trace);

use utf8; # Enable UTF-8 support

=head1 FUNCTIONS

=head2 error

    error(@messages)

The C<error> function generates a formatted error message.

Parameters:
- return=<value>: Set return value (default: 0)
- reset=<value>: Set reset value (default: 0)
- type=<value>: Set error type (default: "FATAL ERROR")
- size=<value>: Set size of formatted message (default: 80)
- trace=<value>: Set trace depth (default: 2)
- noterm=<value>: Set noterm value (default: 0)

Returns the formatted error message as a string.

=cut

sub error {
    my @msg = @_;
    my $return = 0;
    my $reset = 0;
    my $type = "FATAL ERROR";
    my $size = 80 - 2;
    my $trace = 2;
    my $noterm = 0;
    my @lines;

    while (@msg) {
        if (!defined $msg[0]) { 
            shift(@msg);
        }
        elsif ($msg[0] =~ /^return=(.+)$/gs) { 
            $return = $1; 
            shift(@msg);
        }
        elsif ($msg[0] =~ /^reset=(.+)$/gs) { 
            $reset = $1; 
            shift(@msg);
        }
        elsif ($msg[0] =~ /^type=(.+)$/gs) { 
            $type = $1; 
            shift(@msg);
        }
        elsif ($msg[0] =~ /^size=(.+)$/gs) { 
            $size = $1; 
            shift(@msg);
        }
        elsif ($msg[0] =~ /^trace=(.+)$/gs) { 
            $trace = $1; 
            shift(@msg);
        }
        elsif ($msg[0] =~ /^noterm=(.+)$/gs) { 
            $noterm = $1; 
            shift(@msg);
        }
        else { 
            push @lines, split(/\n/, shift(@msg)); 
        }
    }

    $type = " $type ";
    my $tsize = length("$type");
    push @lines, "";

    my $ls = ($size >> 1) - ($tsize >> 1);
    my $rs = $size - ($size >> 1) - ($tsize >> 1) - 1;
    my $tit = " " . ("#" x $ls) . $type . ("#" x $rs) . "\n";
    my $str = "\n\n";

    foreach my $line (@lines) {
        while (length($line) > 0) {
            $str .= " # ";
            if (length($line) > $size) {
                $str .= substr($line, 0, $size - 6) . "..." . " #\n";
                $line = "..." . substr($line, $size - 6);
            } else {
                $str .= $line . ((" " x ($size - length($line) - 3)) > 0 ? (" " x ($size - length($line) - 3)) : '') . " #\n";
                $line = "";
            }
        }
    }

    $str = trace($trace); # Include stack trace if enabled

    if (!$return) {
        $| = 1; # Autoflush STDOUT
        binmode STDOUT, ":encoding(UTF-8)"; # Set UTF-8 encoding for STDOUT
        print STDOUT $str;
        exit 1; # Exit with error status
    }

    return $str;
}

=head2 trace

    trace($depth)

The C<trace> function generates a stack trace with given depth.

Parameters:
- $depth: Depth of the stack trace (default: 1)

Returns the formatted stack trace as a string.

=cut

sub trace {
    my $depth = $_[0] || 1;
    my @out = ();

    while ($depth > 0 && $depth < 20) {
        my ($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash) = caller($depth);
        
        if (!$package) { 
            $depth = 0; 
        } else { 
            push @out, [$line, "$package($filename)", "Calling $subroutine" . ($hasargs ? "@DB::args" : ""), ($subroutine eq '(eval)' && $evaltext ? "[$evaltext]" : "")]; 
            $depth++;
        }
    }

    @out = reverse @out;

    if (@out) {
        for my $i (0 .. $#out) {
            my $dept = "# " . (" " x $i) . ($i > 0 ? "╰[" : "┈[");
            my ($ln, $pk, $cl, $ev) = @{$out[$i]};
            my $ll = (60 - length($dept . $cl));
            my $rr = (6 - length($ln));
            $out[$i] = "$dept $cl" . (" " x ($ll > 0 ? $ll : 0)) . "Line" . (" " x ($rr > 0 ? $rr : 0)) . "$ln : $pk" . ($ev ? "\n$ev" : "");
        }
    }

    return join("\n", @out) . "\n";
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 Domero, Groningen, NL. All rights reserved.

=cut

# EOF gerr.pm (C) 2020 Domero
