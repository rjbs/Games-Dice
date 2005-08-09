use strict;
use Test::More tests => 14;

BEGIN { use_ok("Games::Die"); }

{
  my $die = eval { Games::Die->new(sides => "bananaphone"); };

  # like($@, qr/invalid side/, "got correct warning");
  ok($@, "can't create (sides => 'bananaphone')");
}

{
  my $die = Games::Die->new(6);
  isa_ok($die, 'Games::Die');

  cmp_ok($die->sides,     '==',  6, "six-sided die created");
}

{
  my $die = Games::Die->new(sides => 6);
  isa_ok($die, 'Games::Die');

  cmp_ok($die->sides,     '==',  6, "six-sided die created");

  eval { $die->sides(5); };
  like($@, qr/can't change/, "can't change size of dice");

  cmp_ok($die->sides,     '==',  6, "still a six-sided die");
}

{
  my $die = Games::Die->new(sides => 6);
  isa_ok($die, 'Games::Die');

  cmp_ok($die->sides,     '==',  6, "six-sided die created");

  my ($roll1, $roll2) = ($die->roll, $die->roll);
  ok((defined $roll1 and defined $roll2), "some die rolls return values");
  ok(($roll1 >= 1 and $roll1 <= 6), "roll 1 in range");
  ok(($roll2 >= 1 and $roll2 <= 6), "roll 2 in range");
}

{
  my $die = eval { Games::Die->new(sides => 0); };

  like($@, qr/greater than 0/, "zero sides is not ok");
}

