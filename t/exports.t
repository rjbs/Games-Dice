use Test::More tests => 501;

use strict;
use warnings;

BEGIN { use_ok('Games::Dice', qw(roll)); }

{
  my @sides = (20) x 6;
	SKIP: for my $i (1 .. 500) {
		my @roll = roll('6d20');
		skip "one broke", (500 - $i) unless roll_ok(\@roll, \@sides);
	}
}

sub roll_ok {
  my ($roll, $sides, $options) = @_;
  my $adjust = 0;
  if ($options and $options->{adjust}) { $adjust = $options->{adjust} }
  my $ok = 1;

  foreach my $i (0..@$sides-1) {
    if (!defined $roll->[$i]) {
			diag "die " . ($i+1) . ": rolled an undefined value";
      undef $ok;
      next;
    }
    if ($roll->[$i] < 1) {
      diag "die " . ($i+1) . ": rolled an impossibly-low number: $roll->[$i]\n";
      undef $ok;
      next;
    }
    if ($roll->[$i] > $sides->[$i]) {
      diag "die " . ($i+1) . ": rolled an impossibly high number: $roll->[$i] ($sides->[$i] sides)";
      undef $ok;
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
