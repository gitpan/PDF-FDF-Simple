### -*- mode: perl; -*-

use lib "t/";
use TestHelper qw(:test);

use PDF::FDF::Simple;
use File::Temp qw( tempfile );

use Data::Dumper;
use Parse::RecDescent;
use strict;
use warnings;

BEGIN { $| = 1; print "1..2\n"; }

################## tests ##################


my ($fdf_fh, $fdf_fname) = tempfile (
                                     "/tmp/XXXXXX",
                                     SUFFIX => '.fdf',
                                     UNLINK => 1
                                    );

my $fdf = new PDF::FDF::Simple ({
                                 'filename'     => $fdf_fname
                                });
$fdf->content ({
		'name'                 => 'Blubberman',
		'organisation'         => 'Misc Stuff Ltd.',
		'dotted.field.name'    => 'Hello world.',
		'language.radio.value' => 'French',
		'my.checkbox.value'    => 'On'
	       });
$fdf->save
 ? ok ('save')
 : not_ok ('save');

my $fdf2 = new PDF::FDF::Simple ({
                                  'filename'     => './t/simple.fdf'
                                 });

my $erg = $fdf2->load;

$erg->{'oeavoba.angebotseroeffnung.anschrift'} eq 'Ländliche Neuordnung in Sachsen TG Schönwölkau I, Lüptitzer Str. 39, 04808 Wurzen'
 ? ok ("load")
 : not_ok ("load");

