use strictures;

package Data::UUID::Concise;

use 5.010;
use utf8;
use open qw(:std :utf8);
use charnames qw(:full :short);

use Moo;
use MooX::Types::MooseLike::Base qw(:all);

use Carp;
use Data::UUID;
use Math::BigInt;

use feature qw[ say ];

# VERSION
# ABSTRACT: Encode UUIDs to be more concise or communicable
# ENCODING: utf-8

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Data::UUID::Concise;

    my $foo = Data::UUID::Concise->new();
    ...

=cut

=attr alphabet

=cut

has 'alphabet' => (
	is => 'rw',
	isa => Str,
	default => sub {
		'23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
	},
);

=method encode

=cut

sub encode
{
	my ($self, $uuid) = @_;

	my $output = '';
	my $numeric = Math::BigInt->new((Data::UUID->new)->to_hexstring($uuid));
	my $alphabet_length = length ($self->alphabet);

	while ($numeric->is_positive) {
		my $index = $numeric->copy->bmod($alphabet_length);
		$output .= substr($self->alphabet, $index, 1);
		$numeric->bdiv($alphabet_length);
	}

	return $output;
}

=method decode

=cut

sub decode
{
	my ($self, $string) = @_;

	my $numeric = Math::BigInt->new;
	my @characters = split //, $string;
	my $alphabet_length = length ($self->alphabet);

	for my $character (@characters) {
		my $value = index $self->alphabet, $character;
		$numeric = $numeric->bmul($alphabet_length);
		$numeric = $numeric->badd($value);
	}

	return (Data::UUID->new)->from_hexstring($numeric->as_hex);
}

1;

