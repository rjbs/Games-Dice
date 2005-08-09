use Test::More tests => 4;

use strict;
use warnings;

BEGIN { use_ok('Games::Dice'); }

package Games::Dice::Result::BottomX;

  use base qw(Games::Dice::Result);
  __PACKAGE__->valid_params(
    %{ Games::Dice::Result->valid_params },
    bottom => { regex => qr/\A\d+\Z/, default => undef }
  );

  sub rolls {
    my ($self) = @_;
    my @rolls = sort { $a <=> $b }  @{ $self->{rolls} };
    if ($self->{bottom} and @rolls > $self->{bottom}) {
      @rolls = @rolls[0 .. $self->{bottom} - 1];
    }
    return @rolls;
  }

package main;

{
	my $dice = Games::Dice->new(
    dice => [ 6, 6, 6, 6 ],
    result_class => 'Games::Dice::Result::BottomX',
    bottom       => 3,
  );
  
  isa_ok($dice, 'Games::Dice');

  cmp_ok($dice->roll, '>=', 3, "4d6 (best 3) yields at least 3");

  my @rolls = $dice->result->rolls;

  is(@rolls, 3, "three rolls back (even though four dice rolled)");
}
