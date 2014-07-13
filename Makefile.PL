use ExtUtils::MakeMaker;
use Config;
require 5.006;

warn "\n Version 1.5 (or later) of the mpfi C library\n",
     " (available from https://gforge.inria.fr/projects/mpfi)\n",
     " is needed to build this module\n";

$use_64_bit_int = 0; # Let perl decide whether to include 64-bit 'long long' support
$use_long_double = 0;# Let perl decide whether to include 'long double' support

#$use_64_bit_int = -1; # Force exclusion of 64-bit 'long long' support
#$use_long_double = -1;# Force exclusion of 'long double' support

#$use_64_bit_int = 1; # Force inclusion of 64-bit 'long long' support
#$use_long_double = 1;# Force inclusion of 'long double' support

my $defines = $] < 5.008 ? "-DOLDPERL" : "-DNEWPERL";

if($use_64_bit_int == -1) {}
elsif($use_64_bit_int == 1) {$defines .= " -DUSE_64_BIT_INT"}
else {
  unless($Config::Config{ivsize} < 8) {
    $defines .= " -DUSE_64_BIT_INT";
  }
}

if($use_long_double == -1) {}
elsif($use_long_double == 1) {$defines .= " -DUSE_LONG_DOUBLE"}
else {
  if($Config::Config{nvsize} > 8 ) {
    $defines .= " -DUSE_LONG_DOUBLE";
  }
}

print "\nThis module requires the following C libraries:\n";
print " gmp-4.2.0 (or later)\n mpfr-2.3.0 (or later)\n\n";
$defines =~ /-DUSE_64_BIT_INT/ ? print "Building with 64-bit'long long' support\n" :
                                 print "Building without 64-bit 'long long' support\n";

print "If this is wrong, see the \"64-bit support\" section in the README\n\n";

$defines =~ /-DUSE_LONG_DOUBLE/ ? print "Building with 'long double' support\n" :
                                 print "Building without 'long double' support\n";

print "If this is wrong, see the \"64-bit support\" section in the README\n\n";

my %options = (
  NAME => 'Math::MPFI',
  INC => '',
  AUTHOR => 'Sisyphus (sisyphus at (@) cpan dot (.) org)',
  LIBS => '-lmpfi -lmpfr -lgmp',
  VERSION_FROM => 'MPFI.pm',
  PREREQ_PM => {'Math::MPFR' => '2.01'},
  LICENSE  => 'perl',
  DEFINE   => $defines,
  clean   => { FILES => 'save_child_setting.txt' },
  META_MERGE => {
   'meta-spec' => { version => 2 },
    resources => {
      repository => {
        type => 'git',
        url => 'https://github.com/sisyphus/math-mpfi.git',
        web => 'https://github.com/sisyphus/math-mpfi',
      },
    },
  },
);

WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
