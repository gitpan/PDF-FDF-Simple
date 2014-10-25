### -*- mode: perl; -*-

use PDF::FDF::Simple;
use Test::More;

use Data::Dumper;
use Parse::RecDescent;
use strict;
use warnings;

plan tests => 4;

################## tests ##################

# This real world file contains /F with windowslike filename
# (spaces and parens)
my $fdf_fname = 't/noisyfileattr.fdf';

my $fdf = new PDF::FDF::Simple ({ filename => $fdf_fname });
my $erg = $fdf->load;

is (
    $erg->{'4_Ec_3_equal.Application'},
    'Yes',
    "parse"
   );

is (
    $fdf->attribute_file,
    '/C/Documents and Settings/ajanvier/Local Settings/Temporary Internet Files/OLKCAD/tnt_employee_survey_English_rev3 (5).pdf',
    "attribute_file"
   );

ok (
    (grep '<7D22A3A5BB8F4D3895B909A47FFA6762>', @{$fdf->attribute_id}),
    "attribute_id 1"
   );

ok (
    (grep '<601C7694037F98489E433900ED652316>', @{$fdf->attribute_id}),
    "attribute_id 2"
   );
