### -*- mode: perl; -*-

use lib "t/";
use TestHelper qw(:test);
use PDF::FDF::Simple;

use Data::Dumper;
use strict;
use warnings;

BEGIN { $| = 1; print "1..10\n"; }

################## tests ##################

my $testfile = './t/fdfparser_newline.fdf';
my $parser = new PDF::FDF::Simple ({
                                    filename => $testfile,
                                   });

$parser
 ? ok     ("setting up")
 : not_ok ("setting up");

my $fdf_content_ptr = $parser->load;

$fdf_content_ptr->{'uncomment'} eq ' \ '
 ? ok     ("parsing \\")
 : not_ok ("parsing \\");
$fdf_content_ptr->{'slash r'} eq 'xx'
 ? ok     ("parsing slash r")
 : not_ok ("parsing slash r");
$fdf_content_ptr->{'dM'} eq "x\nx"
 ? ok     ("parsing dM")
 : not_ok ("parsing dM");
$fdf_content_ptr->{'newline n'} eq "xx"
 ? ok     ("parsing newline n")
 : not_ok ("parsing newline n");
$fdf_content_ptr->{'uncomment slash n'} eq 'x\nx'
 ? ok     ("parsing uncomment slash n")
 : not_ok ("parsing uncomment slash n");
$fdf_content_ptr->{'uncomment slash r'} eq 'x\rx'
 ? ok     ("parsing uncomment slash r")
 : not_ok ("parsing uncomment slash r");
$fdf_content_ptr->{'uncomment dM'} eq 'xx'
 ? ok     ("parsing uncomment dM")
 : not_ok ("parsing uncomment dM");
$fdf_content_ptr->{'slash n'} eq "x\nx"
 ? ok     ("parsing slash n")
 : not_ok ("parsing slash n");
$fdf_content_ptr->{'uncomment newline n'} eq "xx"
 ? ok     ("uncomment newline n")
 : not_ok ("uncomment newline n");
