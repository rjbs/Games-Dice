use Test::More tests => 8;

use strict;
use warnings;

BEGIN { use_ok('Games::Dice'); }
BEGIN { use_ok('Games::Die'); }

BEGIN {
  package Games::Die::AlwaysHighest;
  our @ISA = qw(Games::Die);
  use base qw(Games::Die);

  sub roll {
    my $self = shift;
    $self->result_class->new($self->sides);
  }
}

{
  my $dice = Games::Dice->new(
    [ map { Games::Die::AlwaysHighest->new($_) } qw(3 6 10) ],
    { drop_top => 1 },
  );

  isa_ok($dice, 'Games::Dice');

  cmp_ok($dice->roll, '==', 9, "rolled a perfect 9") for (1..5);
}
