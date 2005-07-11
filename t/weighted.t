use Test::More tests => 13;

use strict;
use warnings;

BEGIN { use_ok('Games::Dice'); }

package Games::Die::Weighted;
use base qw(Games::Die);

  __PACKAGE__->valid_params(
    %{ Games::Die->valid_params },
    which_way => { regex => qr/\Ahigh|low\Z/, default => 'high' }
  );

  sub roll {
    my $self = shift;
    return $self->{which_way} eq 'high' ? $self->sides : 0;
  }

package main;

{
  my $dice = Games::Dice->new(
    die_class => 'Games::Die::Weighted',
    dice      => [ 3, 6, 10 ],
  );

  isa_ok($dice, 'Games::Dice');

  cmp_ok($dice->roll, '==', 19, "rolled a perfect 19") for (1..5);
}

{
  my $dice = Games::Dice->new(
    die_class => 'Games::Die::Weighted',
    dice      => [ 3, 6, 10 ],
    which_way => 'low'
  );

  isa_ok($dice, 'Games::Dice');

  cmp_ok($dice->roll, '==',  0, "rolled a perfect 0") for (1..5);
}
