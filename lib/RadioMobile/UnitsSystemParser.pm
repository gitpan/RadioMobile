package RadioMobile::UnitsSystemParser;

use strict;
use warnings;

use Class::Container;
use Params::Validate qw(:types);
use base qw(Class::Container);

__PACKAGE__->valid_params( 
							bfile	=> {isa => 'File::Binary'},
							header => {isa => 'RadioMobile::Header'},
							netsunits => {isa => 'RadioMobile::NetsUnits'},
);

use Class::MethodMaker [ scalar => [qw/header netsunits bfile/] ];

=head1 NAME

RadioMobile::UnitsSystemsParses

=head1 DESCRIPTION

This module parse the UNITS <-> SYSTEMS <-> NETS relation in a .net file
It update the RadioMobile::NetsUnits object args passed in new invoke.

It shows what's the system of every units in every network

=head1 METHODS

=head2 new()

Parameters:

    bfile     => {isa => 'File::Binary'},
    header    => {isa => 'RadioMobile::Header'},
    netsunits => {isa => 'RadioMobile::NetsUnits'}

=cut

sub new {
	my $package = shift;
	my $s = $package->SUPER::new(@_);
	return $s;
}

=head2 parse()

This method read the .net file in bfile and exctract 
$header->networkCount * $header->unitCount * 2 bytes reading it as
a short unsigned integer vector identifing the index of system element
Given A,B,C... units and 1,2,3 Network so A1 is a short 
indicate the system index of unit A in network 1 
It's structure is 
    A1 A2 A3 ... B1 B2 B3 ... C1 C2 C3 ...

=cut

sub parse {
	my $s = shift;
	my $f = $s->bfile;
	my $h = $s->header;
	my $n = $s->netsunits;

	my $skip   = 'x[' . ($h->networkCount-1)*2 .  ']';

	my $len	= $h->unitCount * $h->networkCount * 2;
	my $b = $f->get_bytes($len);

	foreach my $idxNet (0..$h->networkCount-1) {
		my $format = 'x[' . $idxNet * 2  . '](S' .  $skip . ')' 
			. ($s->header->unitCount-1) .  's'; 
		my @row = unpack($format,$b);
		foreach my $idxUnit (0..$h->unitCount-1) {
			$n->at($idxNet,$idxUnit)->system($row[$idxUnit]);
		}
	}

}


1;

__END__
