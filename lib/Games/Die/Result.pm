use warnings;
use strict;

package Games::Die::Result;

=head1 NAME

Games::Die::Result - what you get when you roll one die

=head1 VERSION

version 0.999_01

 $Id: Result.pm 1148 2006-12-08 13:34:36Z rjbs $

=cut

our $VERSION = '0.999_01';

=head1 SYNOPSIS

 my $dic = Games::Die->new(6);
 my $result = $die->roll;
 
 say "You rolled: ",  $result->value;

=head1 DESCRIPTION

Games::Die::Result objects are returned when the C<roll> method is called on a
L<Game::Die> object.

=head1 METHODS

=head2 new

  my $result = Games::Die::Result->new(\%arg);

This method creates a new result.  You shouldn't need to use it outside of
L<Games::Die|Games::Die> classes. 

Valid arguments are:

  value - the value shown on the die

If no other arguments are given, the value of F<value> may be passed as a plain
scalar in place of C<%arg>.

=cut

sub new {
  my ($class, $arg) = @_;
  $arg = { value => $arg } if not ref $arg;

  my $self = bless { value => $arg->{value} } => $class;

  return $self;
}

=head2 value

This method returns the value of the result.

=cut

sub value {
  my ($self) = @_;
  return $self->{value};
}

use overload
  '0+'     => 'value',
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
