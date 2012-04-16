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

has 'alphabet' => (
	is => 'rw',
	isa => Str,
	default => sub {
		'23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
	},
);


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

sub generate_and_encode
{
	my ($self) = @_;
}

sub test
{
	my $uuid = (Data::UUID->new)->from_string('6ca4f0f8-2508-4bac-b8f1-5d1e3da2247a');
	my $duc = Data::UUID::Concise->new;
	say $duc->encode($uuid);

	say "woop" if (Data::UUID->new)->compare($duc->decode($duc->encode($uuid)), $uuid);

	return 1;
}

1;

