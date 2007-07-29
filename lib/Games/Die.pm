use strict;
use warnings;

package Games::Die;

$Games::Die::VERSION = '0.999_01';

use Carp ();
use Games::Die::Result;

=head1 NAME

Games::Die - it's a die; you can roll it!

=head1 VERSION

version 0.999_01

 $Id: Die.pm 1501 2007-07-29 19:50:56Z rjbs $

=head1 SYNOPSIS

	$six_sided = Games::Die->new({ sides => 6 });

	$twenty_sided = Games::Die->new(20);
	$twenty_sided->sides; # 20

	$total = $six_sided->roll + $twenty_sided->roll;

=head1 DESCRIPTION

Games::Die provides an object-oriented implementation of a die that can be
rolled.

=head1 METHODS

=head2 new

  my $die = Games::Die->new(\%arg);
  my $die = Games::Die->new($sides);

This method creates and returns a new Die.	The number of sides must be an
integer greater than zero.  Passing C<$sides> as the first argument is
equivalent to giving that value as the C<sides> argument, and nothing else.

Other parameters will probably appear only in subclasses of Games::Die.

=cut

sub new {
  my ($class, $arg) = @_;
  $arg = { sides => $arg } unless ref $arg;
  my $sides = $arg->{sides};

  Carp::croak "invalid sides argument: $sides"
    unless $sides and $sides !~ /\D/ and $sides > 0;

  bless { sides => $sides } => $class;
}

=head2 sides

This method returns the number of sides on this die.

=cut

sub sides {
  my ($self) = @_;
  $self->{sides};
}

=head2 roll

  my $result = $die->roll;

This method rolls the die and returns a
L<Games::Die::Result|Games::Die::Result> object.

=cut

sub roll {
	my ($self) = @_;

	my $value = int($self->sides * rand) + 1;
  $self->result_class->new($value);
}

=head2 result_class

This method returns the class to be used for results.

=cut

sub result_class { 'Games::Die::Result' }

=head1 AUTHORS

Ricardo SIGNES E<lt>C<rjbs@cpan.org>E<gt>

=head1 LICENSE

Copyright (C) 2005, Ricardo SIGNES.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
