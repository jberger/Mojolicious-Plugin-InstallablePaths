package Mojolicious::Plugin::FileShareDir;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.02';
$VERSION = eval $VERSION;

use File::Spec;
use File::ShareDir ();

has 'app_class';

has 'dist_dir' => sub {
  my $self = shift;
  my $dist = $self->app_class;
  $dist =~ s{::}{-}g;
  return eval { File::ShareDir::dist_dir( $dist ) };
};

has 'class_path' => sub {
  my $self = shift;
  my $app_class = $self->app_class;
  my $class_path = $app_class;
  $class_path =~ s{::}{/}g;

  $class_path = $INC{"$class_path.pm"} 
    || die "Cannot find $class_path.pm, do you need to load $app_class?\n";;
  $class_path =~ s/\.pm$//;
  return $class_path;
};

has 'files_path' => sub {
  my $self = shift;
  return File::Spec->catdir( $self->class_path, 'files');
};

sub register {
  my ($self, $app, $conf) = @_;
  $self->app_class( ref $app );

  if ( my $public = $self->find_path('public') ) {
    $app->static->paths->[0] = $public;
  }

  if ( my $templates = $self->find_path('templates') ) {
    $app->renderer->paths->[0] = $templates;
  }

}

sub find_path {
  my $self = shift;
  my $target = shift;

  my $local = File::Spec->catdir($self->files_path, $target);
  return $local if -d $local;

  my $dist_dir = $self->dist_dir;
  if ( $dist_dir && -d $dist_dir ) {
    my $share = File::Spec->catdir($dist_dir, $target);
    return $share if -d $share;
  }

  return undef;
}

1;

=head1 NAME

Mojolicious::Plugin::FileShareDir - Easy installation configuration for Mojolicious apps

=head1 SYNOPSIS

 # MyApp.pm
 package MyApp;
 use Mojo::Base 'Mojolicious';

 sub startup {
   my $app = shift;
   $app->plugin( 'FileShareDir' );
   ...
 }

then

 # Build.PL
 use Module::Build::Mojolicious;
 my $builder = Module::Build::Mojolicious->new(
   configure_requires => {
     'Module::Build::Mojolicious' => 0,
     'Module::Build' => 0.38,
   },
   ...
 );
 $builder->create_build_script;

or 

 # Makefile.PL
 use ExtUtils::MakeMaker;
 use File::ShareDir::Install::Mojolicious;

 WriteMakefile(
   NAME => with_files 'MyTest::App',
   CONFIGURE_REQUIRES => {
     'File::ShareDir::Install::Mojolicious' => 0,
     'ExtUtils::MakeMaker' => 0,
   },
   ...
 );

=head1 DESCRIPTION

L<Mojolicious> applications work nicely from a working directory, but once the app is bundled for installation some of the configuration gets a little bit tricky. Though some examples are shown in the L<Mojolicious> documentation, the process is still rather involved. However, L<Mojolicious::Plugin::FileShareDir> handles all the configuration for you (provided you follow a proscribed directory tree)!

=head1 DIRECTORY STRUCTURE

 myapp                              # Application directory
 |- bin                             # Script directory
 |  +- myapp                        # Application script
 |- lib                             # Library directory
 |  |- MyApp.pm                     # Application class
 |  +- MyApp                        # Application namespace
 |     |- Example.pm                # Controller class
 |     +- files                     # Shared directory for all non-module content
 |        |- public                 # Static file directory (served automatically)
 |        |  +- index.html          # Static HTML file
 |        +- templates              # Template directory
 |           |- layouts             # Template directory for layouts
 |           |  +- default.html.ep  # Layout template
 |           +- example             # Template directory for "Example" controller
 |              +- welcome.html.ep  # Template for "welcome" action
 |- t                               # Test directory
 |  +- basic.t                      # Random test
 +- Build.PL                        # Build file uses Module::Build::Mojolicious

As you can see, all non-module content is placed inside a directory named C<files> directly inside the folder named for the module. In the above example this is the C<lib/MyApp/files/> directory. If the app had been C<Some::App> then the directory would be C<lib/Some/App/files/>.

If it exists, this folder is automatically added to the list of shared directories installed by the appropriate build-chain's L<File::ShareDir> integration (see below). Later, this directory can be found using the usual mechanisms that that system provides.

There is no allowance for different names of these folders nor of different locations for them relative to the main module. Patches will be considered, but the primary purpose of this module is the simple generic case; to do strange things the Mojolicious path manipulation system should be used directly.

=head1 PLUGIN

The magic happens when your app loads the C<FileShareDir> plugin.

 $app->plugin('FileShareDir');

Before this call, the directories are not set correctly, so be sure to use it early! The plugin will detect if the directory tree exists as above (i.e. before installation) and use it directly or else it will attempt to use the L<File::ShareDir> system to locate the directories (i.e. after installation). In this way, your app should always find its needed files, no matter what phase of development or installation!

=head1 BUILD.PL SCRIPT

Included with L<Mojolicious::Plugin::FileShareDir> is a subclass of L<Module::Build> named L<Module::Build::Mojolicious> (of course). The purpose of this subclass is to add the necessary directory to the list of shared folders. This is done completely behind the scenes, provided the directory exists. Simply change the name of your build module and use as normal:

 use Module::Build::Mojolicious;
 my $builder = Module::Build::Mojolicious->new(
   configure_requires => {
     'Module::Build::Mojolicious' => 0,
     'Module::Build' => 0.38,
   },
   ...
 );
 $builder->create_build_script;

=head1 MAKEFILE.PL SCRIPT

If L<ExtUtils::MakeMaker> is more you flavor, also included is L<File::ShareDir::Install::Mojolicious> which is a wrapper of L<File::ShareDir::Install> for use with L<Mojolicious>. See L<Mojolicious::Plugin::FileShareDir> for more documentation.

This module exports the function C<with_files> which takes exactly one argument, the name of the module to be installed. This then sets up the necessary information that L<File::ShareDir::Install> needs for installing the non-module content via L<File::ShareDir>.

Note that C<with_files> returns the name that was given as an argument, so that it can be inlined in the definition of C<NAME> during the call to C<WriteMakefile()> (see L</SYNOPSIS>).

 # Makefile.PL
 use ExtUtils::MakeMaker;
 use File::ShareDir::Install::Mojolicious;

 WriteMakefile(
   NAME => with_files 'MyTest::App',
   CONFIGURE_REQUIRES => {
     'File::ShareDir::Install::Mojolicious' => 0,
     'ExtUtils::MakeMaker' => 0,
   },
   ...
 );

=head1 KEEP IN MIND

Remember that since the install-time helpers are needed by C<Build.PL> or C<MakeFile.PL>, C<Module::Build::Mojolicious> or C<File::ShareDir::Install::Mojolicious> needs to be added to the C<configure_requires> or C<CONFIGURE_REQUIRES> hash respectively. This tells your CPAN installer that those modules must be available before the script can be run. This should be done for any module used within those build scripts.

=head1 SEE ALSO

=over

=item *

L<Module::Build>

=item * 

L<Mojolicious>

=back

=head1 SOURCE REPOSITORY

L<http://github.com/jberger/Mojolicious-Plugin-FileShareDir>

=head1 AUTHOR

Joel Berger, E<lt>joel.a.berger@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Joel Berger

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


