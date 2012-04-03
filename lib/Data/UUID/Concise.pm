use strictures;

package Data::UUID::Concise;

use 5.010;
use utf8;
use open qw(:std :utf8);
use charnames qw(:full :short);

use Moose;

use Data::UUID;
use Math::BigInt;

use feature qw[ say ];

=head1 NAME

Data::UUID::Concise - The great new Data::UUID::Concise!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Data::UUID::Concise;

    my $foo = Data::UUID::Concise->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=cut

has 'alphabet' => (
	is => 'rw',
	isa => 'Str',
	default => '23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz',
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

=head1 AUTHOR

Nathaniel Reindl, C<< <nrr at corvidae.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-data-uuid-concise at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-UUID-Concise>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Data::UUID::Concise


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-UUID-Concise>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Data-UUID-Concise>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Data-UUID-Concise>

=item * Search CPAN

L<http://search.cpan.org/dist/Data-UUID-Concise/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Nathaniel Reindl.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

no Moose;
__PACKAGE__->meta->make_immutable;

exit test() unless caller(0);
