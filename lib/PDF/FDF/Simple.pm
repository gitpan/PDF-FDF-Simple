package PDF::FDF::Simple;

use strict;
use warnings;

use vars qw($VERSION);
use Data::Dumper;
use Parse::RecDescent;

$VERSION = '0.03';

#RecDescent Environment variables: enable for Debugging
#$::RD_TRACE = 1;
#$::RD_HINT  = 1;

use Class::MethodMaker
 get_set => [
             'filename',
             'content',
             'errmsg',
             'parser',
            ],
 new_with_init => 'new',
 new_hash_init => 'hash_init',
 ;

# for substituting ^M or \r to \n
my $bslashR = "\r"; # TODO: does'nt work yet, should be used in fieldvalue

sub _pre_init {
  my $self = shift;
  $self->errmsg ('');
}

# setting up grammar
sub _post_init {
  my $self = shift;

  my $recdesc = new Parse::RecDescent(
       q(
         startrule : fdf_head objlist fdf_tail
                      {
                        $return = $item{objlist};
                      }

         fdf_head : '%FDF-' version garbage | <error>

         objlist : obj objlist
                   {
                     push ( @{$return}, $item{obj}, @{$item{objlist}} );
                   }
                 | # empty
                   {
                      $return = [];
                   }
                 | <error>

         obj : /\d+/ /\d+/ 'obj' objbody 'endobj'
               { $return = $item{objbody}; }
               | <error>

         objbody : obj1
                 | obj2
                 | obj3
                 | <error>

         obj1 : ot objcontent1 ct
               { $return = $item{objcontent1}; }
             | <error>

         obj2 : objcontent2
               { $return = $item{objcontent2}; }
             | <error>

         obj3 : ot objcontent3 ct
               { $return = $item{objcontent3}; }
             | <error>

         fdf_tail : 'trailer' ot '/Root 1 0 R' ct rest | <error>

         ot : '<<' | <error>        #opening tags
         ct : '>>' | <error>        #closing tags
         ob : '(' | <error>         #opening braces
         cb : ')' | <error>         #closing braces
         obt : '[' | <error>        #opening brackets
         cbt : ']' | <error>        #closing brackets

         filetype : '/FDF'
                  | <error>

         objcontent1 : filetype ot '/Fields' obt fieldlist cbt footer ct
                       {
                         $return = $item{fieldlist};
                       } 
                     | filetype ot footer '/Fields' obt fieldlist cbt ct
                       {
                         $return = $item{fieldlist};
                       }
                       | <error>

         objcontent2 : obt fieldlist cbt
                       {
                         $return = $item{fieldlist};
                       }
                       | <error>

         objcontent3 : filetype ot '/Fields' objreference ct
                       {
                         $return = []; #$item{fieldlist};
                       }
                       | <error>

         objreference : /\d+/ /\d+/ 'R'
                      | <error>

         fieldlist : field fieldlist
                     {
                       push ( @{$return}, $item{field}, @{$item{fieldlist}} );
                     }
                   | ot fieldname kids ct fieldlist
                     {
                       my $fieldlist;
                       foreach my $ref ( @{$item{kids}} ) {
                         my %kids = %{$ref};
                         foreach my $key (keys %kids) {
                           push (@{$fieldlist},{$item{fieldname}.".".$key=>$kids{$key}});
                         }
                       }
                       push ( @{$return}, @{$fieldlist}, @{$item{fieldlist}} );
                     }

                   | ot kids fieldname ct fieldlist
                     {
                       my $fieldlist;

                       foreach my $ref ( @{$item{kids}} ) {
                         my %kids = %{$ref};
                         foreach my $key (keys %kids) {
                           push (@{$fieldlist},{ $item{fieldname}.".".$key=>$kids{$key}});
                         }
                       }
                       push ( @{$return}, @{$fieldlist}, @{$item{fieldlist}} );
                     }

                   |
                     {
                      $return = [];
                     }
                   | <error>

         kids : '/Kids' obt fieldlist cbt
                     {
                       $return = $item{fieldlist};
                     }
              | <error>

         field : ot fieldvalue fieldname ct
                 {
                   $return = { $item{fieldname} => $item{fieldvalue} };
                 }

               | ot fieldname fieldvalue ct
                 {
                   $return = { $item{fieldname} => $item{fieldvalue} };
                 }

               | <error>

         fieldvalue : '/V' ob <skip:""> value <skip:$item[3]> cb
                      {
                        $return = $item{value};
                        $return =~ s/\\\\(\d{3})/sprintf ("%c", oct($1))/eg;   #handle octals
                        $return =~ s/\\#([0-9A-F]{2})/sprintf ("%c",  hex($1))/eg;   # hexals
                      }
                    | '/V' feature
                      {
                        $return = substr ($item{feature},1);
                        $return =~ s/\\\\(\d{3})/sprintf ("%c", oct($1))/eg;
                        $return =~ s/\\#([0-9A-F]{2})/sprintf ("%c",  hex($1))/eg;
                      }
                    | <error>

         fieldname : '/T' ob name cb
                     {
                        $return = $item{name};
                        $return =~ s/\\\\(\d{3})/sprintf ("%c", oct($1))/eg;
                        $return =~ s/\\#([0-9A-F]{2})/sprintf ("%c",  hex($1))/eg;
                     }
                   | <error>

         value : '\\\\\\\\'  value
                 {
                   $return = chr(92).$item{value};
                 }
               | '\\\\#' value
                 {
                  $return = "#".$item{value};
                 }
               | '\\\\\\\\r' value
                 {
                   $return = '\r'.$item{value};
                 }
               | '\\\\\\\\t' value
                 {
                   $return = '\t'.$item{value};
                 }
               | '\\\\\\\\n' value
                 {
                   $return = '\n'.$item{value};
                 }
               | '\\\\\r' value
                 {
                   $return = ''.$item{value};
                 }
               | '\\\\\n' value
                 {
                   $return = ''.$item{value};
                 }
               | '\\\\r' value
                 {
                   $return = chr(13).$item{value};
                 }
               | '\\\\n' value
                 {
                   $return = chr(10).$item{value};
                 }
               | '\r' value
                 {
                   $return = ''.$item{value};
                 }
               | '\t' value
                 {
                   $return = "\t".$item{value};
                 }
               | '' value
                 {
                   $return = chr(10).$item{value};
                 }
               | '\\\\' value
                 {
                   $return = ''.$item{value};
                 }
               | /\n/ value #'\n' value
                 {
                   $return = ''.$item{value};
                 }
               |  m/\\\\/ m/\n/ value
                 {
                   $return = ''.$item{value};
                 }

               | '\\\\(' value
                 {
                   $return = '('.$item{value};
                 }
               | '\\\\)' value
                 {
                   $return = ')'.$item{value};
                 }
               | /([^()])/ value
                 {
                   $return = $item[1].$item{value};
                 }
               | # empty
                 {
                  $return = "";
                 }
               |<error>

         feature :  m!/[^\s/>]*!  | <error> #m!/[^\s]*!  | <error>

         version : /[0-9]+\.[0-9]+/
                 | <error>
         garbage : /%.*/
                 | # empty
                 | <error>
         rest :  /.*/ | <error>

         footer : '/F' ob name cb id | | <error>

         name : /([^\)][\s]*)*/   | <error>     # one symbol but not \)

         id : '/ID' obt idnum idnum  cbt
            | # empty, no id
            | <error>
         idnum : '<' /[(\w)*(\d)*]*/ '>'
               | ob /([^()])*/ cb
               | <error>
        ));
  $self->parser ($recdesc);
}

sub init {
  my $self = shift;
  $self->_pre_init(@_);
  $self->hash_init(@_);
  $self->_post_init(@_);
  return $self;
}


sub _fdf_header {
  my $self = shift;
  return <<__EOT__;
%FDF-1.2

1 0 obj
<<
/FDF << /Fields 2 0 R >>
>>
endobj
2 0 obj
[
__EOT__
}

sub _fdf_footer {
  my $self = shift;
  return <<__EOT__;
]
endobj
trailer
<<
/Root 1 0 R

>>
%%EOF
__EOT__
}

sub _quote {
  my $self = shift;
  my $str = shift;
  $str =~ s,\\,\\\\,g;
  $str =~ s,\(,\\(,g;
  $str =~ s,\),\\),g;
  $str =~ s,\n,\\r,gs;
  return $str;
}

sub _fdf_field_formatstr {
  my $self = shift;
  return "<< /T (%s) /V (%s) >>\n"
}

sub as_string {
  my $self = shift;
  my $fdf_string = $self->_fdf_header;
  foreach (sort keys %{$self->content}) {
    $fdf_string .= sprintf ($self->_fdf_field_formatstr,
			    $_,
			    $self->_quote($self->content->{$_}));
  }
  $fdf_string .= $self->_fdf_footer;
  return $fdf_string;
}

sub save {
  my $self = shift;
  open (F, "> ".$self->filename) or do {
    $self->errmsg ('error: open file ' . $self->filename);
    return 0;
  };

  print F $self->as_string;
  close (F);

  $self->errmsg ('');
  return 1;
}

sub _read_fdf {
  my $self = shift;
  my $filecontent;

  # read file to be checked
  open FH, "< ".$self->filename or return -1;
  {
    local $/;
    $filecontent = <FH>;
  }
  close FH;
  return $filecontent;
}

sub _map_parser_output {
  my $self   = shift;
  my $output = shift;

  my $fdfcontent = {};
  foreach my $obj ( @$output ) {
    foreach my $contentblock ( @$obj ) {
      foreach my $keys (keys %$contentblock) {
        $fdfcontent->{$keys} = $contentblock->{$keys};
      }
    }
  }
  return $fdfcontent;
}

sub load {
  my $self = shift;
  my $filecontent = shift;

  $filecontent = $self->_read_fdf unless $filecontent;
  my $output = $self->parser->startrule ($filecontent);
  $self->content ($self->_map_parser_output ($output));
  $self->errmsg ("Corrupt FDF file!\n") unless $self->content;
  return $self->content;
}

1;
