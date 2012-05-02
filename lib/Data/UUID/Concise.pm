use strictures 1;

package Data::UUID::Concise;

use 5.010;
use utf8;
use open qw(:std :utf8);
use charnames qw(:full :short);

use Moo;
use MooX::Types::MooseLike::Base qw(:all);

use Carp;
use Data::UUID;
use List::MoreUtils qw[ uniq ];
use Math::BigInt;

# VERSION
# ABSTRACT: Encode UUIDs to be more concise or communicable
# ENCODING: utf-8

=head1 SYNOPSIS

    use Data::UUID::Concise;

    my $duc = Data::UUID::Concise->new();
    my $encoded_uuid = $duc->encode((Data::UUID->new)->create);
    my $decoded_uuid = $duc->decode('M55djt9tt4WoFaL68da9Ef');

    $duc->alphabet('aaaaabcdefgh1230123');
    $duc->alphabet; # 0123abcdefgh

=cut

=attr alphabet

This is the collection of symbols that are used for the encoding
scheme.

By default, a reasonably unambiguous set of characters is used that is
reminiscent of the base 58 scheme used by a rather prominent photo
site's URL shortener.

=cut

has 'alphabet' => (
    is      => 'rw',
    isa     => Str,
    default => sub {
        '23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    },
    trigger => sub {
    	my ($self, @rest) = @_;
    	$self->_normalize_alphabet(@rest);
    },
);

=method _normalize_alphabet

Private method. Normalize the alphabet such that it is sorted and that
all elements are distinct.

=cut

sub _normalize_alphabet
{
    my ($self, $alphabet_candidate) = @_;

    my @symbols = split //, $alphabet_candidate;
    my @decruftified_symbols = uniq sort { $a cmp $b } @symbols;
    my $decruftified_alphabet = join '', @decruftified_symbols;

    return $self->alphabet($decruftified_alphabet);
}

=method encode

Encode a Data::UUID instance as a string with the appropriate set of
symbols.

=cut

sub encode
{
    my ( $self, $uuid ) = @_;

    my $output = '';
    my $numeric =
        Math::BigInt->new( ( Data::UUID->new )->to_hexstring( $uuid ) );
    my $alphabet_length = length( $self->alphabet );

    while ( $numeric->is_positive ) {
        my $index = $numeric->copy->bmod( $alphabet_length );
        $output .= substr( $self->alphabet, $index, 1 );
        $numeric->bdiv( $alphabet_length );
    }

    return $output;
}

=method decode

Decode a string with the appropriate set of symbols and return a
Data::UUID instance representing the decoded UUID.

=cut

sub decode
{
    my ( $self, $string ) = @_;

    my $numeric         = Math::BigInt->new;
    my @characters      = split //, $string;
    my $alphabet_length = length( $self->alphabet );

    for my $character ( @characters ) {
        my $value = index $self->alphabet, $character;
        $numeric = $numeric->bmul( $alphabet_length );
        $numeric = $numeric->badd( $value );
    }

    return ( Data::UUID->new )->from_hexstring( $numeric->as_hex );
}

1;

