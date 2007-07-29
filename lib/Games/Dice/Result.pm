use warnings;
use strict;

package Games::Dice::Result;

use List::Util ();

=head1 NAME

Games::Dice::Result - what you get when you roll some dice

=head1 VERSION

version 0.999_01

 $Id: Result.pm 1499 2007-07-29 19:15:29Z rjbs $

=cut

our $VERSION = '0.999_01';

=head1 SYNOPSIS

 my $dice = Games::Dice->new("3d6");
 my $result = $dice->roll;
 
 say "You rolled: ",  $result->as_string;

=head1 DESCRIPTION

Result objects are returned when the C<roll> method is called on a
L<Game::Dice> set.

=head1 METHODS

=head2 new

  my $result = Games::Dice::Result->new(\%arg);

This method creates a new result.  You shouldn't need to use it outside of
L<Games::Dice|Games::Dice> classes. 

Valid arguments are:

  results - (required) an arrayref of Games::Die::Result objects
  dropped - (optional) an arrayref of Games::Die::Result objects
  adjust  - (optional) a coderef

=cut

sub new {
  my ($class, $arg) = @_;

  my $self = bless {} => $class;

  $self->{results} = [ @{ $arg->{results} } ];
  $self->{dropped} = [ @{ $arg->{dropped} } ];

  $self->{adjust} = $arg->{adjust};

  return $self;
}

=head2 results

This method returns all the non-dropped Games::Die::Result objects for this
result.

=cut

sub results {
  my ($self) = @_;
  return @{ $self->{results} };
}

=head2 dropped_results

This returns a list of the result of each die rolled, in the order the results
were given to the constructor.

=cut

sub dropped_results {
  my ($self) = @_;
	return @{ $self->{dropped} };
}

=head2 all_results

This returns both kept and dropped die results for this object.

=cut

sub all_results {
  my ($self) = @_;
  return ($self->results, $self->dropped_results);
}

=head2 total

This returns the total of the rolls, plus the adjustment.

=cut

sub total {
	my ($self) = @_;

	my $total = 0;
	$total += $_->value for $self->results;

  if ($self->{adjust}) {
    if (ref $self->{adjust} eq 'CODE') { $total = $self->{adjust}->($total) }
    else { $total += $self->{adjust} }
  }

	return $total;
}

=head2 as_string

This method returns a string describing the results.  The default
implementation will return something like this (though this is likely to
change):

  1 + 2 + 4 + 4 + 8 = 19 + 2 = 21

=cut

sub as_string {
  my ($self) = @_;

  my @values = sort { $a <=> $b } map { $_->value } $self->results;

  my $string = join q{ + }, @values;
  $string .= ' ' . List::Util::sum @values;
  if (my $adj = $self->{adjust}) {
    if (ref $adj) {
      $string .= ' (adjusted to) ';
    } else {
      $string .= ' ' . ($adj > 0 ? '+' : '-') . " $adj = ";
    }
  }

  $string .= $self->total;
}

use overload
  '0+'     => 'total',
  fallback => 1,
;

=head1 AUTHOR

Ricardo SIGNES, <C<rjbs@cpan.org>>

=head1 BUGS

Please report any bugs or feature requests to C<bug-games-dice@rt.cpan.org>, or
through the web interface at L<http://rt.cpan.org>.  I will be notified, and
then you'll automatically be notified of progress on your bug as I make
changes.

=head1 COPYRIGHT

Copyright 2005, Ricardo SIGNES.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
