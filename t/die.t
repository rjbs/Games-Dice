use strict;
use Test::More tests => 13;

BEGIN { use_ok("Games::Die"); }

{
  my $die = eval { Games::Die->new('bananaphone'); };

  like($@, qr/invalid side/, "got correct warning");
  ok($@, "can't create (sides => 'bananaphone')");
}

{
  my $die = Games::Die->new(6);
  isa_ok($die, 'Games::Die');

  cmp_ok($die->sides, '==',  6, "six-sided die created");
}

{
  my $die = Games::Die->new({ sides => 6 });
  isa_ok($die, 'Games::Die');

  cmp_ok($die->sides, '==',  6, "six-sided die created");
}

{
  my $die = Games::Die->new({ sides => 6 });
  isa_ok($die, 'Games::Die');

  cmp_ok($die->sides, '==',  6, "six-sided die created");

  my ($roll1, $roll2) = ($die->roll, $die->roll);
  ok((defined $roll1 and defined $roll2), "some die rolls return values");
  ok(($roll1->value >= 1 and $roll1->value <= 6), "roll 1 in range");
  ok(($roll2->value >= 1 and $roll2->value <= 6), "roll 2 in range");
}

{
  my $die = eval { Games::Die->new(0); };

  like($@, qr/invalid sides/, "zero sides is not ok");
}

