#!/usr/bin/perl -w
#opendir(D, "") || die "Can't opedir: $!\n";
#while (my $f = readdir(D)) {
#  print "\$f = $f\n";
#}
#closedir(D);

$ano = 2008;
#caioformiga on 16-ou-2012
#change from 3099999 to 3088196 after exaustive searching current range
$x = 3088196; 
$y = 2933685; 
while ($x > $y) {
	system ("wget 'http://www.asclaras.org.br/\@doador.php?doador=$x&ano=$ano'");
	$x--;	
}

#on bathka running
#$X = 2933685;
#$y = 2779028; 
