package TestHelper;

use strict;
use warnings;

use base 'Exporter';
@TestHelper::EXPORT_OK = qw( ok not_ok);
%TestHelper::EXPORT_TAGS = (
                            test => [ qw( ok not_ok ) ]
                           )
;

my $test = 1;

sub ok {
  my $text = shift || '';
  print "ok $test $text\n";
  $test++;
}

sub not_ok {
  my $text = shift || '';
  print "not ok $test $text\n";
  $test++;
}

1;
