use Test::More tests => 4011;

use strict;
use warnings;

BEGIN { use_ok('Games::Dice'); }

{
	my $dice = eval { Games::Dice->new("10z12"); };
	is($dice, undef, "10z12 isn't a valid dice spec");

	like($@, qr/invalid specification/, "got correct exception");
}

{
	my $dice = eval { Games::Dice->new([ bless {} => 'Widget' ]); };
	is($dice, undef, "passed an unrollable die");

	like($@, qr/invalid object/, "got correct exception");
}

{
	my $dice = eval { Games::Dice->new([]); };
	is($dice, undef, "dice must have at least one die");
  
  like($@, qr/at least one/, "got correct exception");
}

{
	my @sides = (20) x 6;
	my $dice = Games::Dice->new('6d20');

	isa_ok($dice, 'Games::Dice');

	SKIP: for my $i (1 .. 1000) {
		my $result = $dice->roll;
		skip "one broke", (1000 - $i) unless roll_ok($result, \@sides);
	}
}

{
	my @sides = (6) x 3;
	my $dice = Games::Dice->new("3d6+1");
	isa_ok($dice,"Games::Dice");

	SKIP: for my $i (1 .. 1000) {
		skip "one broke", (1000 - $i)
			unless roll_ok($dice->roll, \@sides, { adjust => 1 });
	}
}

{
	my @sides = (6) x 3;
	my $dice = Games::Dice->new(\@sides, { adjust => 1 });
	isa_ok($dice,"Games::Dice");

	SKIP: for my $i (1 .. 1000) {
		skip "one broke", (1000 - $i)
			unless roll_ok($dice->roll, \@sides, { adjust => 1 });
	}
}

{
	my @sides = (6) x 3;

	my $dice = Games::Dice->new(
    [ map { Games::Die->new({ sides => 6 }) } (0 .. 2) ]
  );

	isa_ok($dice,"Games::Dice");

	SKIP: for my $i (1 .. 1000) {
		skip "one broke", (1000 - $i)
			unless roll_ok($dice->roll, \@sides, { adjust => 1 });
	}
}

sub roll_ok {
  my ($roll, $sides, $options) = @_;
  my $adjust = 0;
  if ($options and $options->{adjust}) { $adjust = $options->{adjust} }
  my $ok = 1;

  my @values = map { $_->value } $roll->all_results;
  foreach my $index (0 .. $#values) {
    if (!defined $values[$index]) {
			diag "Die #" . ($index+1) . ": rolled an undefined value";
      undef $ok;
      next;
    }
    if ($values[$index] < 1) {
      diag "Die #" . ($index+1) . ": rolled an impossibly-low number: $values[$index]\n";
      undef $ok;
      next;
    }
    if ($values[$index] > $sides->[$index]) {
      diag "Die #" . ($index+1) . ": rolled an impossibly high number: $values[$index] ($sides->[$index] sides)";
      $ok = undef;
      next;
    }
  }

  my ($minimum, $maximum) = (-$adjust, +$adjust);
  $maximum += $_ for @$sides;
	
  my $total = $roll->total;

	if ($total > $maximum) {
		diag "total roll ($total) exceeds maximum ($maximum)";
		undef $ok;
	} elsif ($total < $minimum) {
		diag "total roll ($total) falls short of minimum ($minimum)";
		undef $ok;
	}

  return ok($ok);
}

