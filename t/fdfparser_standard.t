### -*- mode: perl; -*-

use lib "t/";
use TestHelper qw(:test);
use PDF::FDF::Simple;

use Data::Dumper;
use strict;
use warnings;

BEGIN { $| = 1; print "1..18\n"; }

################## tests ##################

my $testfile = './t/fdfparser_standard.fdf';
my $parser = new PDF::FDF::Simple ({
                                    filename => $testfile,
                                   });

$parser
 ? ok     ("setting up")
 : not_ok ("setting up");

my $fdf_content_ptr = $parser->load;

$fdf_content_ptr->{'root.data.plzort'} eq '01069'
 ? ok     ("parsing file - digits")
 : not_ok ("parsing file - digits");
$fdf_content_ptr->{'root.parentA.kidA_A'} eq 'valueA_A'
 ? ok     ("parsing file - parent / child")
 : not_ok ("parsing file - parent / child");
$fdf_content_ptr->{'root.data.ort'} eq 'Dresden'
 ? ok     ("parsing file - characters")
 : not_ok ("parsing file - characters");
$fdf_content_ptr->{'root.checkbox1'} eq 'OFF'
 ? ok     ("parsing file - special values")
 : not_ok ("parsing file - special values");
$fdf_content_ptr->{'root.specials.parenthesize'} eq ' (parenthesize) '
 ? ok     ("parsing file - parenthesize")
 : not_ok ("parsing file - parenthesize");
$fdf_content_ptr->{'root.specials.hexa'} eq 'zufällig'
 ? ok     ("parsing file - hexa")
 : not_ok ("parsing file - hexa");
$fdf_content_ptr->{'root.parentB.kidB_B'} eq 'valueB_B'
 ? ok     ("parsing file - parent / child")
 : not_ok ("parsing file - parent / child");
$fdf_content_ptr->{'root.parentB.kidB_A'} eq 'valueB_A'
 ? ok     ("parsing file - parent / child")
 : not_ok ("parsing file - parent / child");
$fdf_content_ptr->{'root.specials.backspace'} eq ' \ '
 ? ok     ("parsing file - backspaces")
 : not_ok ("parsing file - backspaces");
$fdf_content_ptr->{'root.data.name'} eq 'some company Inc'
 ? ok     ("parsing file - characters")
 : not_ok ("parsing file - characters");
$fdf_content_ptr->{'root.specials.rhomb'} eq '#'
 ? ok     ("parsing file - rhomb")
 : not_ok ("parsing file - rhomb");
$fdf_content_ptr->{'root.data.'} eq ''
 ? ok     ("parsing file - empty")
 : not_ok ("parsing file - empty");
$fdf_content_ptr->{'root.specials.slash'} eq ' / '
 ? ok     ("parsing file - slash")
 : not_ok ("parsing file - slash");
$fdf_content_ptr->{'root.checkbox2'} eq 'ON'
 ? ok     ("parsing file - special values")
 : not_ok ("parsing file - special values");
$fdf_content_ptr->{'root.specials.spaces'} eq '  2x space at start and end  '
 ? ok     ("parsing file - spaces")
 : not_ok ("parsing file - spaces");
$fdf_content_ptr->{'root.data.email'} eq 'info@doo.de'
 ? ok     ("parsing file - special characters")
 : not_ok ("parsing file - special characters");


my $keys = keys %{$fdf_content_ptr};
$keys == 17
 ? ok     ("number of key-value pairs")
 : not_ok ("number of key-value pairs");
