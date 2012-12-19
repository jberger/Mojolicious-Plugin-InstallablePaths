use strict;
use warnings;

chdir 't' or die 'Cannot chdir into t/';

use Test::More;
use Module::Build::Mojolicious;

my $build = Module::Build::Mojolicious->new(
  module_name => 'MyTest::App',
);

my $share_dir = $build->share_dir->{dist}[0];
ok( $share_dir, 'share_dir populated' );
ok( -d $share_dir, 'share_dir populated correctly' );

ok( exists $build->prereq_data->{requires}{'File::ShareDir'}, 'File::ShareDir added to requires' );

done_testing;

