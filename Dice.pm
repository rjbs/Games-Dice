package Games::Dice;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;

@ISA = qw(Exporter);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT_OK = qw(
	roll roll_array
);
$VERSION = '0.02';


# Preloaded methods go here.


sub roll ($) {
    my($line, $dice_string, $sign, $offset, $sum, @throws, @result);

    $line = shift;

    return undef unless $line =~ m{
                 ^              # beginning of line
                 (              # dice string in $1
                   (?:\d+)?     # optional count
                   [dD]         # 'd' for dice
                   (?:          # type of dice:
                      \d+       # either one or more digits
                    |           # or
                      %         # a percent sign for d% = d100
                   )
                 )
                 (?:            # grouping-only parens
                   ([-+xX*/bB]) # a + - * / b(est) in $2
                   (\d+)        # an offset in $3
                 )?             # both of those last are optional
              }x;               # whitespace allowed

    $dice_string = $1;
    $sign        = $2 || '';
    $offset      = $3 || 0;

    $sign        = lc $sign;

    @throws = roll_array( $dice_string );
    return undef unless @throws;

    if( $sign eq 'b' ) {
        $offset = 0       if $offset < 0;
        $offset = @throws if $offset > @throws;

        @throws = sort { $b <=> $a } @throws;   # sort numerically, descending
        @result = @throws[ 0 .. $offset-1 ];    # pick off the $offset first ones
    } else {
        @result = @throws;
    }

    $sum = 0;
    $sum += $_ foreach @result;
    $sum += $offset if  $sign eq '+';
    $sum -= $offset if  $sign eq '-';
    $sum *= $offset if ($sign eq '*' || $sign eq 'x');
    do { $sum /= $offset; $sum = int $sum; } if $sign eq '/';

    return $sum;
}

sub roll_array ($) {
    my($line, $num, $type, @throws);

    $line = shift;

    return undef unless $line =~ m{
                 ^      # beginning of line
                 (\d+)? # optional count in $1
                 [dD]   # 'd' for dice
                 (      # type of dice in $2:
                    \d+ # either one or more digits
                  |     # or
                    %   # a percent sign for d% = d100
                 )
              }x;       # whitespace allowed

    $num    = $1 || 1;
    $type   = $2;

    $type  = 100 if $type eq '%';

    @throws = ();
    for( 1 .. $num ) {
        push @throws, int (rand $type) + 1;
    }

    return @throws;
}



1;
__END__

=head1 NAME

Games::Dice - Perl module to simulate die rolls

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
hence, rolling 2d% and 2d100 is equivalent. C<roll> simulates I<a> rolls
of I<b>-sided dice and adds together the results. The optional end,
consisting of one of +-*/b and a number I<c>, can modify the sum of the
individual dice. +-*/ are similar in that they take the sum of the rolls
and add or subtract I<c>, or multiply or divide the sum by I<c>. (x can
also be used instead of *.) Hence, 1d6+2 gives a number in the range
3..8, and 2d4*10 gives a number in the range 20..80. (Using / truncates
the result to an int after dividing.) Using b in this slot is a little
different: it's short for "best" and indicates "roll a number of dice,
but add together only the best few". For example, 5d6b3 rolls five six-
sided dice and adds together the three best rolls. This is sometimes
used, for example, in roll-playing to give higher averages.

Generally, C<roll> probably provides the nicer interface, since it does
the adding up itself. However, in some situations one may wish to
process the individual rolls (for example, I am told that in the game
Feng Shui, the number of dice to be rolled cannot be determined in
advance but depends on whether any 6's were rolled); in such a case, one
can use C<roll_array> to return an array of values, which can then be
examined or processed in an application-dependent manner.

This having been said, comments and additions (especially if accompanied
by code!) to Games::Dice are welcome. So, using the above example, if
anyone wishes to contribute a function along the lines of roll_feng_shui
to become part of Games::Dice (or to support any other style of die
rolling), you can contribute it to the author's address, listed below.

=head1 AUTHOR

Philip Newton, <pne@cpan.org>

=head1 LICENCE

Copyright (C) 1999, 2002 Philip Newton
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

=over 4

=item *

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer. 

=item *

Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution. 

=back

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

=head1 SEE ALSO

perl(1).

=cut
