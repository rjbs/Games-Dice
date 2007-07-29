use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'Games::Dice',
  AUTHOR        => 'Ricardo SIGNES <rjbs@cpan.org>',
  VERSION_FROM  => 'lib/Games/Dice.pm',
  ABSTRACT_FROM => 'lib/Games/Dice.pm',
  LICENSE       => 'perl',
  PL_FILES      => {},
  PREREQ_PM => {
    'Class::Container' => 0,
    'Test::More'       => 0,
  },
  dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean         => { FILES => 'Games-Dice-* cover_db' },
);
