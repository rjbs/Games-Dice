use strict;
use warnings;
use 5.010;
package Games::Dice;
# ABSTRACT: Perl module to simulate die rolls

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw( roll roll_array);

# Preloaded methods go here.

# Win32 has crummy built in rand() support
# So let's use something that's decent and pure perl
use if $^O eq "MSWin32", 'Math::Random::MT::Perl' => qw(rand);

sub parse_spec {
    my $line = shift;
    return undef unless $line =~ m{
                 ^                 # beginning of line
                 (                 # dice string in $1
                   (?<count>\d+)?  # optional count
                   [dD]            # 'd' for dice
                   (?<type>        # type of dice:
                      \d+          # either one or more digits
                    |              # or
                      %            # a percent sign for d% = d100
                    |              # pr
                      F            # a F for a fudge dice
                   )
                 )
                 (?:               # grouping-only parens
                   (?<sign>[-+xX*/bB])  # a + - * / b(est) in $2
                   (?<offset>\d+)  # an offset in $3
                 )?                # both of those last are optional
                 \s*               # possibly some trailing space (like \n)
                 $
              }x;    # whitespace allowed

    my %pr;
    $pr{$_} = $+{$_} for keys %+;

    $pr{sign}   ||= '';
    $pr{offset} ||= 0;
    $pr{count}  ||= 1;

    $pr{sign} = lc $pr{sign};

    return \%pr;

}

sub roll ($) {
    my $line = shift;
    my @result;

    return $line if $line =~ /\A[0-9]+\z/;

    my $pr = parse_spec($line);
    return undef unless $pr;

    my @throws = _roll_dice($pr);
    return undef unless @throws;

    my ( $sign, $offset ) = @$pr{qw(sign offset)};

    if ( $sign eq 'b' ) {
        $offset = 0       if $offset < 0;
        $offset = @throws if $offset > @throws;

        @throws = sort { $b <=> $a } @throws;  # sort numerically, descending
        @result = @throws[ 0 .. $offset - 1 ]; # pick off the $offset first ones
    }
    else {
        @result = @throws;
    }

    my $sum = 0;
    $sum += $_ foreach @result;
    $sum += $offset if $sign eq '+';
    $sum -= $offset if $sign eq '-';
    $sum *= $offset if ( $sign eq '*' || $sign eq 'x' );
    do { $sum /= $offset; $sum = int $sum; } if $sign eq '/';

    return $sum;
}

sub _roll_dice {
    my $pr = shift;

    my ($type,$num) = @$pr{qw(type count)};

    my $throw = sub { int( rand $_[0] ) + 1 };

    if ( $type eq '%' ) {
        $type = 100;
    }
    elsif ( $type eq 'F' ) {
        $throw = sub { int( rand 3 ) - 1 };
    }

    my @throws;
    for ( 1 .. $num ) {
        push @throws, $throw->( $type );
    }
    return @throws;
}

sub roll_array ($) {
    my $line = shift;

    return $line if $line =~ /\A[0-9]+\z/;

    my $pr = parse_spec($line);
    return unless $pr;

    return _roll_dice($pr);
}

1;
__END__

=head1 NAME


=head1 SYNOPSIS

  use Games::Dice 'roll';
  $strength = roll '3d6+1';

  use Games::Dice 'roll_array';
  @rolls = roll_array '4d8';

=head1 DESCRIPTION

Games::Dice simulates die rolls. It uses a function-oriented (not
object-oriented) interface. No functions are exported by default. At
present, there are two functions which are exportable: C<roll> and
C<roll_array>. The latter is used internally by C<roll>, but can also be
exported by itself.

The number and type of dice to roll is given in a style which should be
familiar to players of popular role-playing games: I<a>dI<b>[+-*/b]I<c>.
I<a> is optional and defaults to 1; it gives the number of dice to roll.
I<b> indicates the number of sides to each die; the most common,
cube-shaped die is thus a d6. % can be used instead of 100 for I<b>;
hence, rolling 2d% and 2d100 is equivalent. If F is used for I<b> fudge
dice are used, which either results in -1, 0 or 1. C<roll> simulates I<a>
rolls of I<b>-sided dice and adds together the results. The optional end,
consisting of one of +-*/b and a number I<c>, can modify the sum of the
individual dice. +-*/ are similar in that they take the sum of the rolls
and add or subtract I<c>, or multiply or divide the sum by I<c>. (x can
also be used instead of *.) Hence, 1d6+2 gives a number in the range
3..8, and 2d4*10 gives a number in the range 20..80. (Using / truncates
the result to an int after dividing.) Using b in this slot is a little
different: it's short for "best" and indicates "roll a number of dice,
but add together only the best few". For example, 5d6b3 rolls five six-
sided dice and adds together the three best rolls. This is sometimes
used, for example, in role-playing to give higher averages.

Generally, C<roll> probably provides the nicer interface, since it does
the adding up itself. However, in some situations one may wish to
process the individual rolls (for example, I am told that in the game
Feng Shui, the number of dice to be rolled cannot be determined in
advance but depends on whether any 6s were rolled); in such a case, one
can use C<roll_array> to return an array of values, which can then be
examined or processed in an application-dependent manner.

This having been said, comments and additions (especially if accompanied
by code!) to Games::Dice are welcome. So, using the above example, if
anyone wishes to contribute a function along the lines of roll_feng_shui
to become part of Games::Dice (or to support any other style of die
rolling), you can contribute it to the author's address, listed below.

=cut
