use strictures;
use Data::UUID;
use Data::UUID::Concise;
use Test::More tests => 301;

{
	my $uuid = (Data::UUID->new)->from_string('6ca4f0f8-2508-4bac-b8f1-5d1e3da2247a');
	my $duc = Data::UUID::Concise->new;

	ok((Data::UUID->new)->compare($duc->decode($duc->encode($uuid)), $uuid));
}

{
	my $duc = Data::UUID::Concise->new;

	for my $i (1..300) {
		my $uuid = (Data::UUID->new)->create;

		ok((Data::UUID->new)->compare($duc->decode($duc->encode($uuid)), $uuid));
	}
}

done_testing;
