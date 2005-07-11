package Games::Dice::Result;
use base qw(Class::Container);
use Params::Validate qw(:types);

use warnings;
use strict;

=head1 NAME

Games::Dice::Result - what you get when you roll some dice

=head1 VERSION

version 0.99_01

 $Id: Result.pm,v 1.1 2004/10/19 03:52:28 rjbs Exp $

=cut

our $VERSION = '0.99_01';

=head1 SYNOPSIS

 my $dice = Games::Dice->new("3d6");

 # get a sorted list of 6 results
 my @results = sort { $b->value <=> $a->value }
               map  { $dice->roll }
               (1 .. 6);

 print "best roll: ",  join(' ', sort $results[0]->rolls), "\n";
 print "worst roll: ", join(' ', sort $results[9]->rolls), "\n";

=head1 DESCRIPTION

Result objects are returned when the C<roll> method is called on a
L<Game::Dice> set.

=head1 METHODS

=head2 C<< Games::Dice::Result->new() >>

This method creates a new result.  You shouldn't need to use it outside of
L<Games::Dice> classes. 

It takes a C<rolls> parameter, an arrayref of die values; an C<adjust>
parameter, an integer to add to the total or coderef to call on it; and a
C<top> parameter, the number of results to return (choosing the highest results
first).

=cut

__PACKAGE__->valid_params(
  rolls  => { type => ARRAYREF},
  adjust => { type => UNDEF | SCALAR | CODEREF,     optional => 1 },
  top    => { type => SCALAR, regex => qr/\A\d+\Z/, optional => 1 }
);

=head2 rolls

This returns a list of the die results.

=cut

sub rolls {
  my ($self) = @_;
  return $self->all_rolls unless defined $self->{top};
  my @rolls = sort { $a <=> $b }  @{ $self->{rolls} };
  if ($self->{top} and @rolls > $self->{top}) {
    @rolls = @rolls[0 .. $self->{top} - 1];
  }
  return @rolls;
}

=head2 all_rolls

This returns a list of the result of each die rolled, in the order the results
were given to the constructor.

=cut

sub all_rolls {
	my $self = shift;
	return @{ $self->{rolls} };
}


=head2 total

This returns the total of the rolls, plus the adjustment.

=cut

sub total {
	my $self = shift;

	my $total = 0;
	$total += $_ for $self->rolls;
  if ($self->{adjust}) {
    if (ref $self->{adjust} eq 'CODE') { $total = $self->{adjust}->($total) }
    else { $total += $self->{adjust} }
  }
	return $total;
}

=head2 value

In list context, this calls C<rolls>; otherwise, it calls C<total>.

=cut

sub value {
	my $self = shift;

	return wantarray ? $self->rolls
	                 : $self->total;
}

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
