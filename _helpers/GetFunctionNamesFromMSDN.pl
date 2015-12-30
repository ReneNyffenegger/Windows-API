#
#  TODO: functions by Category: https://msdn.microsoft.com/en-us/library/aa383686%28v=vs.85%29.aspx
#
use warnings;
use strict;

use WWW::Mechanize;
use HTML::TreeBuilder::XPath;

GetFunctionsInAlphabeticalOrder();

sub GetFunctionsInAlphabeticalOrder {

  open (my $out_alphabetical, '>', 'alphabetical.html') or die;

  print $out_alphabetical "<!doctype html>
<html>
<head>
<title>Windows API - Alphabetically</title>
<script>

function toggleVisibility (div_id) {
  var elem = document.getElementById(div_id);

  if(elem.style.visibility=='visible'){
     elem.style.visibility='hidden';
     elem.style.display   ='none';
  } else {
     elem.style.visibility='visible';
     elem.style.display   ='block';
  }
};
</script>
<style type='text/css'>

  * { font-family: Helvetica; sans-serif}

</style>
</head>
<body>";

  my $mech = new WWW::Mechanize;
  $mech->get('https://msdn.microsoft.com/en-us/library/aa383688%28v=vs.85%29.aspx');
  
  my @links = $mech -> links();
  
  for my $link (grep {$_->text() =~ /^. Functions$/} @links) {
    FunctionsOfLetter(substr($link->text(), 0, 1), $link->url(), $out_alphabetical);
  }

  print $out_alphabetical "</body></html>";

  close $out_alphabetical;
}

sub FunctionsOfLetter {
  my $letter = shift;
  my $url    = shift;
  my $out    = shift;

  my $first = 1;

  print $out qq{<h2 onclick="toggleVisibility('letter_$letter')">$letter</h2>};

  print $out qq{<div id="letter_$letter" style='visibility:hidden;display:none'>};

  my $mech = new WWW::Mechanize;
  $mech->get($url);

  my $tree = new HTML::TreeBuilder::XPath;
  $tree -> parse($mech->content);
  my @nodes = $tree -> findnodes('//a/strong');

  for my $html_elem (@nodes) { # @nodes is a list of HTML::Element's
     unless ($first) {
       print $out "<br>";
     }
     $first = 0;
     print $out $html_elem->as_text();
  }

  print $out "</div>\n";
}
