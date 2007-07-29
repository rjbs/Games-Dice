use strict;
use warnings;

package Games::Dice;

use Games::Die;
use Games::Dice::Result; 

use Carp ();

$Games::Dice::VERSION = '0.999_02';

use Sub::Exporter -setup => {
  exports => { roll => \'_build_roll' },
};

sub _build_roll {
  my ($class, $name) = @_;
  sub {
    my $result = $class->roll(@_);
    if (wantarray) {
      return map { $_->value } $result->results;
    } else {
      return $result->total;
    }
  };
}

=head1 NAME

Games::Dice - a set of dice for rolling

=head1 VERSION

version 0.999_02

 $Id: Dice.pm 1504 2007-07-29 20:13:18Z rjbs $

=head1 SYNOPSIS

  my $die_pool = Games::Dice->new('2d8');

  my $hit_points = $die_pool->roll->total;

  my $damage_dice = Games::Dice->new('2d6+2');
  
  my $result = Games::Dice->roll(
    [
      Games::Die->new({ sides => 6 }),
      6,
      Games::Die::Weighted->new({ sides => 6 }),
    ],
    {
      drop_bottom => 1
    },
  );

  print "You rolled: ", $result->as_string, "\n";

=head1 DESCRIPTION

A Games::Dice object represents a set of dice, which are represented by
Games::Die objects.  A set of dice can be rolled, and returns a
Games::Dice::Results object.  The default behavior of dice and dice sets is
simple, but can easily be augmented with subclassing.

=head1 METHODS

=head2 new

  my $dice = Games::Dice->new($dice, \%arg);

This method creates and returns a new set of dice.

The simplest kind of value for C<$dice> is a string describing the dice in the
usual RPG format: C<XdY+Z>

I<X>, the number of dice, is optional.  I<Y>, the sides on each die, is
mandatory, and must be a positive integer, or the percent sign, which stands in
for 100.  I<+Z>, the modifier, is optional, and may be a positive or negative
integer.

Instead of a string, you can provide an arrayref of individual dice.  Each
entry in the arrayref must be an integer (in which case it's used to create a
new Games::Die object with that many sides) or a Games::Die object.

Valid arguments (to pass in C<%arg>) are:

=over

=item adjust

This parameter may be either a number to add to the rolled total or a coderef
that is called on the total.  The result of that call is then returned as the
total.  In other words, the following two calls are functionally equivalent:

  Games::Dice->new('2d10', { adjust => -1 });
  Games::Dice->new('2d10', { adjust => sub { $_[0] - 1 } });

In a case like the following, the net result is an adjust of +2:

  Games::Dice->new("3d6+1", { adjust => 1 });

=item drop_bottom

=item drop_top

These parameters indicate that the higher and lowest I<n> values should not be
considered toward the total and should not be returned in the normal set of
results.  (See the C<L</results>> method, below.)

In other words, this set of dice rolls four six-sided dice, then drops the
lowest value:

  my $dark_sun_dice = Games::Dice->new("4d6", { drop_bottom => 1 });

=back

=cut

my $dice_spec_re = qr/
  \A
  (\d+)?     # a number
  d(%|\d+)   # of x-sided dice (% for 100)
  ([-+]\d+)? # posibly followed by +n or -n
  \z
/x;

sub _expand_spec {
  my ($self, $spec) = @_;

  if (my ($count, $sides, $adjust) = $spec =~ $dice_spec_re) {
    $sides = 100 if $sides eq '%';

    Carp::croak "can't create a zero-die set" if $count == 0;

    return ($count, $sides, $adjust);
  }
  
  Carp::croak "invalid specification $spec";
}

sub new {
  my ($class, $dice, $arg) = @_;
  $arg ||= {};

  my $self = bless {} => $class;

  if (not ref $dice) {
    my ($count, $sides, $adjust) = $self->_expand_spec($dice);

    $dice = [ ($sides) x $count ];

    if ($adjust) {
      if (not $arg->{adjust}) {
        $arg->{adjust} = $adjust;
      } elsif (not ref $arg->{adjust}) {
        $arg->{adjust} += $adjust;
      } else {
        my $existing = $arg->{adjust};
        $arg->{adjust} = sub { $existing->($_[0] + $adjust) };
      }
    }
  }

  # There's nothing wrong with one die object being given in multiple slots in
  # the dice arrayref, so we'll use %basic_for to maximize doing that.  --
  # rjbs, 2007-07-29
  my %basic_for;
  my @dice;
  for (@$dice) {
    $_ = ($basic_for{$_} ||= $self->die_class->new($_)) unless ref;
    Carp::croak "invalid object in dice: $_" unless $_->isa($self->die_class);
    push @dice, $_;
  }

  Carp::croak "a dice set must have at least one die" unless @dice;

  $self->{dice}   = \@dice;
  $self->{adjust} = $arg->{adjust};

  # XXX: Validate! -- rjbs, 2007-07-29
  $self->{drop_top}    = $arg->{drop_top} || 0;
  $self->{drop_bottom} = $arg->{drop_bottom} || 0;
  
  return $self;
}

=head2 dice

  my @dice = $dice->dice;

This returns a list of the die objects in the set.

=cut

sub dice {
  my ($self) = @_;
  @{ $self->{dice} };
}


=head2 roll

  my $result = $dice->roll;
  my $result = Games::Dice->roll(@args_for_new);

This method rolls the dice and returns a Result object.

=cut

sub roll {
  my ($self) = @_;

  if (not ref $self) {
    Carp::croak "roll as a class method requires arguments" unless @_ > 1;
    $self = shift->new(@_);
  }

  my @results = sort { $a->value <=> $b->value } map { $_->roll } $self->dice;
  my @dropped;

  push @dropped, splice @results, 0, $self->{drop_bottom};
  push @dropped, splice @results, -$self->{drop_top}, $self->{drop_top};

  $self->result_class->new({
    results => \@results,
    dropped => \@dropped,
    adjust  => $self->{adjust},
  });
}

=head2 die_class

This method returns the class to be used for die objects.

=cut

sub die_class { 'Games::Die' }

=head2 result_class

This method returns the class to be used for results.

=cut

sub result_class { 'Games::Dice::Result' }

=head1 TODO

=over

=item * White Wolf dice (diff/successes)

=item * roll-more-on-high-roll (Feng Shui, etc)

=item * faces (roll things other than 1 .. C<$n>)

=item * per-die adjustments

=item * backward-compatible functional interface

=back

=head1 AUTHOR

Ricardo SIGNES <C<rjbs@cpan.org>>

=head1 HISTORY

Games::Dice was originally uploaded by Philip Newton (pne@cpan.org) in 1999 and
provided a simple function-based interface to die rolling.

Andrew Burke (burke@bitflood.org) and Jeremy Muhlich (jmuhlich@bitflood.org)
uploaded Games::Die::Dice in 2002, which provided a simple object-oriented
interface to dice sets.

Ricardo SIGNES (rjbs@cpan.org) took maintainership of Games::Die::Dice in 2004,
and really did mean to get around to overhauling it.  In 2005 he got a round
tuit and rewrote the code to be more flexible and extensible for all the silly
things he wanted to do.  He also took maintainership of Games::Dice, and merged
the two distributions.  In 2007, he really, really overhauled it again, getting
rid of the insane things he had done in a long-standing developer-only release.

=head1 LICENSE

Copyright 2005, Ricardo SIGNES.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

