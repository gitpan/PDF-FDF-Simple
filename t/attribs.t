### -*- mode: perl; -*-

use lib "t/";
use TestHelper qw(:test);

use PDF::FDF::Simple;
use File::Temp qw( tempfile );

use Data::Dumper;
use Parse::RecDescent;
use strict;
use warnings;

BEGIN { $| = 1; print "1..4\n"; }

################## tests ##################


my $fdf_fname = 't/hundev1.fdf';
my $fdf = new PDF::FDF::Simple ({
                                 'filename' => $fdf_fname,
                                });
my $erg = $fdf->load;

$erg->{'Zu- und Vorname'} eq 'Steffen Schwigon'
 and $erg->{'PLZ'} eq '01159'
 and $erg->{'Anschrift Behörde'} eq "Hundeanstalt\rGroßraum DD"
 ? ok ("parse")
 : not_ok ("parse");

$fdf->attribute_file eq 'hundev1.pdf'
 ? ok ("attribute_file")
 : not_ok ("attribute_file");

grep '<ece53a3b05e57db38ed6f01c29a13ced>', @{$fdf->attribute_id}
 ? ok ("attribute_id 1")
 : not_ok ("attribute_id 1");

grep '<54034b0e4698f348e8b2a91d70e5736b>', @{$fdf->attribute_id}
 ? ok ("attribute_id 2")
 : not_ok ("attribute_id 2");

