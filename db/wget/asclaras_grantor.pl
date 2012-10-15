#!/usr/bin/perl -w
#opendir(D, "") || die "Can't opedir: $!\n";
#while (my $f = readdir(D)) {
#  print "\$f = $f\n";
#}
#closedir(D);

$ano = 2008;
$x = 3099999;
$y = 2779028;
while ($x > $y) {
	system ("wget 'http://www.asclaras.org.br/\@doador.php?doador=$x&ano=$ano'");
	$x--;	
}
