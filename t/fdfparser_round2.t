### -*- mode: perl; -*-

use lib "t/";
use TestHelper qw(:test);
use PDF::FDF::Simple;

use Data::Dumper;
use strict;
use warnings;

BEGIN { $| = 1; print "1..6\n"; }

############################################################
#
# This test script is similar to fdfparser_round.t, but uses
#  as_string() and load($string) instead of files.
#
############################################################

################## tests ##################

my $readonly_testfile = './t/fdfparser_standard.fdf';

#first parser reads and parses a given fdf file
my $parser = new PDF::FDF::Simple ({
                                    filename => $readonly_testfile,
                                   });
$parser
 ? ok     ("setting up 1")
 : not_ok ("setting up 1");

my $fdf_content_ptr = $parser->load;
scalar keys %$fdf_content_ptr == 17
 ? ok     ("parsing 1")
 : not_ok ("parsing 1");

my $fdf_string = $parser->as_string;

#second parser parses the fdf content
my $parser2 = new PDF::FDF::Simple();
$parser2
 ? ok     ("setting up 2")
 : not_ok ("setting up 2");

my $new_fdf_content = $parser2->load ($fdf_string);
scalar keys %$new_fdf_content
 ? ok     ("parsing 1")
 : not_ok ("parsing 1");

scalar keys %$new_fdf_content == scalar keys %$fdf_content_ptr
 ? ok     ("compare size")
 : not_ok ("compare size");

my $compare_success = 1;

foreach my $key (keys %$new_fdf_content) {
  if ( $new_fdf_content->{$key} ne $fdf_content_ptr->{$key} ) {
    $compare_success = 0;
    print "error\n";
    last;
  }
}
$compare_success
 ? ok     ("compare")
 : not_ok ("compare");
