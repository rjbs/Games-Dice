use Test::More tests => 4013;

use strict;
use warnings;

BEGIN { use_ok('Games::Dice'); }

{
	my $dice = eval { Games::Dice->new("10z12"); };
	is($dice, undef, "10z12 isn't a valid dice spec");

	like($@, qr/invalid specification/, "got correct exception");
}

{
	my $dice = eval { Games::Dice->new(dice => [ bless {} => 'Widget' ]); };
	is($dice, undef, "passed an unrollable die");

	like($@, qr/invalid object/, "got correct exception");
}

{
	my $dice = Games::Dice->new(dice => []);
	is($dice, undef, "dice must have at least one die");
}

{
	my @sides = (20) x 6;
	my $dice = Games::Dice->new('6d20');
	isa_ok($dice, 'Games::Dice');

	SKIP: for my $i (1 .. 1000) {
		my @roll = $dice->roll;
		skip "one broke", (1000 - $i) unless roll_ok(\@roll, \@sides);
	}
}

{
	my @sides = (6) x 3;
	my $dice = Games::Dice->new("3d6+1");
	isa_ok($dice,"Games::Dice");
	cmp_ok($dice->roll, '>', 4, "minimum roll reached");

	SKIP: for my $i (1 .. 1000) {
		my @roll = $dice->roll;
		skip "one broke", (1000 - $i)
			unless roll_ok(\@roll, \@sides, { adjust => 1 });
	}
}

{
	my @sides = (6) x 3;
	my $dice = Games::Dice->new(dice => \@sides, adjust => 1);
	isa_ok($dice,"Games::Dice");
	cmp_ok($dice->roll, '>', 4, "minimum roll reached");

	SKIP: for my $i (1 .. 1000) {
		my @roll = $dice->roll;
		skip "one broke", (1000 - $i)
			unless roll_ok(\@roll, \@sides, { adjust => 1 });
	}
}

{
	my @sides = (6) x 3;
	my $dice = Games::Dice->new(dice => [ map { Games::Die->new(sides => 6) } (0 .. 2) ]);
	isa_ok($dice,"Games::Dice");
	cmp_ok($dice->roll, '>', 4, "minimum roll reached");

	SKIP: for my $i (1 .. 1000) {
		my @roll = $dice->roll;
		skip "one broke", (1000 - $i)
			unless roll_ok(\@roll, \@sides, { adjust => 1 });
	}
}

sub roll_ok {
  my ($roll, $sides, $options) = @_;
  my $adjust = 0;
  if ($options and $options->{adjust}) { $adjust = $options->{adjust} }
  my $ok = 1;

  foreach my $index (0..@$sides-1) {
    if (!defined $roll->[$index]) {
			diag "Die #" . ($index+1) . ": rolled an undefined value";
      undef $ok;
      next;
    }
    if ($roll->[$index] < 1) {
      diag "Die #" . ($index+1) . ": rolled an impossibly-low number: $roll->[$index]\n";
      undef $ok;
      next;
    }
    if ($roll->[$index] > $sides->[$index]) {
      diag "Die #" . ($index+1) . ": rolled an impossibly high number: $roll->[$index] ($sides->[$index] sides)";
      $ok = undef;
      next;
    }
  }

  my ($minimum, $maximum) = (-$adjust, +$adjust);
  $maximum += $_ for @$sides;
  my $total = 0;
  $total += $_ for @$roll;
	
	if ($total > $maximum) {
		diag "total roll ($total) exceeds maximum ($maximum)";
		undef $ok;
	} elsif ($total < $minimum) {
		diag "total roll ($total) falls short of  minimum ($minimum)";
		undef $ok;
	}

  return ok($ok);
}

