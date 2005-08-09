package Games::Die;
use base qw(Class::Container);
use Params::Validate qw(:types);

use strict;
use warnings;

use Carp;

use vars qw($VERSION);
$VERSION = '0.99_01';

=head1 NAME

Games::Die - it's a die; you can roll it!

=head1 VERSION

version 0.99_01

 $Id: Die.pm,v 1.5 2004/10/19 03:52:28 rjbs Exp $

=head1 SYNOPSIS

	$six_sided = Games::Die->new(sides => 6);

	$twenty_sided = Games::Die->new(20);
	$twenty_sided->sides; # 20

	$total = $six_sided->roll() + $twenty_sided->roll();

=head1 DESCRIPTION

Games::Die provides an object-oriented implementation of a polyhedral die that
can be rolled.



=head1 METHODS

=cut

=head2 C<< new(sides => $sides) >>

This method creates and returns a new Die.	The number of sides must be an
integer greater than zero.  If you only need to pass C<sides>, you can omit the
name, as follows:

 my $d6 = Games::Die->new(6);

Other parameters will probably appear only in subclasses of Games::Die.

=cut

__PACKAGE__->valid_params(
  sides => { type  => SCALAR,
             regex => qr/\A\d+\Z/,
             callbacks => { 'greater than 0' => sub { no warnings; shift() > 0 } }
           }
);

sub new {
  my $class = shift;
  unshift @_, "sides" if @_ == 1;

  $class->SUPER::new(@_);
}

=head2 C<< $die->sides() >>

This method returns the number of sides on this die.

=cut

sub sides {
  my ($self) = @_;
  croak "can't change sidedness of die" if @_ > 1;
  $self->{sides};
}

=head2 C<< $die->roll() >>

Rolls the die and returns the number that came up.

=cut

sub roll {
	my $self  = shift;

	return int($self->sides * rand) + 1;
}

=head1 TODO

see L<Games::Dice>

=head1 AUTHORS

Ricardo SIGNES E<lt>C<rjbs@cpan.org>E<gt>

=head1 LICENSE

Copyright (C) 2005, Ricardo SIGNES.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
