use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Games::Dice',
    'VERSION_FROM' => 'Dice.pm', # finds $VERSION
);
