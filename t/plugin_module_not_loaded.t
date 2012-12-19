use strict;
use warnings;

use Test::More;

use lib 't/lib';

use Mojolicious::Plugin::ModuleBuild;
my $plugin = Mojolicious::Plugin::ModuleBuild->new( app_class => 'MyTest::App' );

isa_ok $plugin, 'Mojolicious::Plugin';

eval { $plugin->files_path };
ok( $@, 'dies when app class is not loaded' );

done_testing;

