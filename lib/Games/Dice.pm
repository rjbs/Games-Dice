package Games::Dice;
use base qw(Class::Container);
use Params::Validate qw(:types);

use strict;
use warnings;

use Games::Die;
use Games::Dice::Result; 

use Carp;

use vars qw($VERSION);
$VERSION = '0.99_01';

=head1 NAME

Games::Dice - a set of dice for rolling

=head1 VERSION

version 0.99_01

 $Id: Dice.pm,v 1.6 2004/10/19 12:52:29 rjbs Exp $

=head1 SYNOPSIS

  my $hit_points = Games::Dice->new('2d8');

  my $result = $hit_points->roll;

  my $damage_dice = Games::Dice->new(dice => [6,6], adjust => +2);

=head1 DESCRIPTION

A Games::Dice object represents a set of dice, which are represented by
Games::Dice objects.  A set of dice can be rolled, and returns a
Games::Dice::Results object.  The default behavior of dice and dice sets is
simple, but can easily be augmented with subclassing.

=head1 METHODS

=head2 C<< Games::Dice->new(dice => $dice, adjust => $adjust) >>

This method creates and returns a new set of dice.

The C<dice> parameter is an arrayref of dice or dice sides that make up the
set.  The dice may be numbers or objects that provide a C<roll> method.
Alternately, C<dice> may be a string describing the dice set (see below).

The C<adjust> parameter may be either a number to add to the rolled total or a
coderef that is called on the total.  The result of that call is then returned
as the total.  In other words, the following two calls are functionally
equivalent:

  Games::Dice->new(dice => [ 10, 10 ], adjust => -1);
  Games::Dice->new(dice => [ 10, 10 ], adjust => sub { $_[0] - 1 });

These two parameters can be combined in a traditional dice specification and
passed as the C<dice> parameter, as a string.

  Games::Dice->new(dice => "3d6");   # same as: dice => [ 6, 6, 6 ]
  Games::Dice->new(dice => "2d4+1"); # same as: dice => [ 4, 4 ], adjust => 1
  Games::Dice->new(dice => "d8*2");  # same as: dice => [ 8 ],
                                                adjust => sub { $_[0] * 2 }
  

If the only parameter you pass to C<new> is C<dice>, you can omit the name.

  my $dexterity = Games::Dice->new("3d6+1")->roll;

C<die_class> and C<result_class> parameters may be passed to Games::Dice to
change the class that will be used to create individual dice or the result set.
Any parameters intended for those constructors will be passed along.  (See
L<Class::Container> for more information.)

=cut

__PACKAGE__->valid_params(
  spec   => { type => SCALAR,   optional => 1 },
  dice   => { type => ARRAYREF, optional => 1 },
);

__PACKAGE__->contained_objects(
  die    => { class => 'Games::Die',          delayed => 1 },
  result => { class => 'Games::Dice::Result', delayed => 1 },
);

my $dice_spec_re = qr/\A
                      (\d+)?        # a number
                      d(%|\d+)      # of x-sided dice (% for 100)
                      (?:([-+\/*])  # followed by an operator
                         (\d+)      # ...and number
                      )?            # ...maybe
                      \Z
                     /ix;

sub _expand_spec {
  my ($spec) = @_;

  if (my ($dice, $sides, $op, $adjust) = $spec =~ $dice_spec_re) {
    $sides = 100 if $sides eq '%';
    $op ||= '+';

    my %param;
    $param{dice} = [ ($sides) x ($dice || 1) ];

    croak "can't divide result by zero" if $op eq '/' and $adjust == 0;

       if ($op eq '+') { $param{adjust} = + $adjust }
    elsif ($op eq '-') { $param{adjust} = - $adjust }
    elsif ($op eq '*') { $param{adjust} = sub {      $_[0] * $adjust  } }
    elsif ($op eq '/') { $param{adjust} = sub { int( $_[0] / $adjust) } }
    else               { $param{adjust} = undef }

    return %param;
  }
  
  croak "invalid specification";
}

sub new {
  my $class = shift;

  unshift @_, "spec" if @_ == 1;

  my $self = $class->SUPER::new(@_);

  if ($self->{spec}) {
    my %spec = _expand_spec($self->{spec});
    $self->{$_} = $spec{$_} for qw(dice adjust);
  }

  return unless @{$self->{dice}};

  for (@{ $self->{dice} }) {
    if (ref $_) {
      next if $_->can('roll');
      croak "invalid object in dice list: " . ref $_;
    }
    $_ = $self->create_delayed_object(die => (sides => $_));
  }
  
  return $self;
}

=head2 C<< $dice->dice() >>

This returns a list of the die objects in the set.

=cut

sub dice {
  my ($self) = @_;
  @{$self->{dice}};
}


=head2 C<< $dice->roll_result() >>

This method rolls the dice and returns a Result object.

=cut

sub roll_result {
  my ($self) = @_;

  $self->{last_result} = $self->create_delayed_object(result =>
    rolls  => [ map { $_->roll } $self->dice ],
    adjust => $self->{adjust}
  );
}

=head2 C<< $dice->roll() >>

This method rolls the dice and returns the value of the result.  Generally, in
scalar context, this returns the sum, in list context, returns the list of
values that came up on each die.  (Other result classes may change the behavior
of the C<value> method.)

=cut

sub roll {
  my ($self) = @_;

  $self->roll_result->value;
}

=head2 C<< $dice->result() >>

This method returns the last result of rolling the dice.  (This method doesn't
roll the dice, so you'll need to call C<roll> first.)

=cut

sub result {
  my ($self) = @_;
  $self->{last_result};
}

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

Games::Dice was originally uploaded by Philip Newton (pne@cpan.org) in 1999 and provided
a simple function-based interface to die rolling.

Andrew Burke (burke@bitflood.org) and Jeremy Muhlich (jmuhlich@bitflood.org)
uploaded Games::Die::Dice in 2002, which provided a simple object-oriented
interface to dice sets.

Ricardo SIGNES (rjbs@cpan.org) took maintainership of Games::Die::Dice in 2004,
and really did mean to get around to overhauling it.  In 2005 he got a round
tuit and rewrote the code to be more flexible and extensible for all the silly
things he wanted to do.  He also took maintainership of Games::Dice, and merged
the two distributions.

=head1 LICENSE

Copyright 2005, Ricardo SIGNES.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;

