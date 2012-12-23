use strict;
use warnings;

chdir 't' or die 'Cannot chdir into t/';

use Test::More;

use File::ShareDir::Install::Mojolicious;

is( 
  MY->can('postamble'), 
  File::ShareDir::Install->can('postamble'), 
  'postamble installed'
);

is with_files 'MyTest::App', 'MyTest::App', 'with_files returns module name';

ok -d $File::ShareDir::Install::DIRS[0], 'File::ShareDir::Install knows about files';

done_testing;

