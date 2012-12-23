package File::ShareDir::Install::Mojolicious;

use strict;
use warnings;

our $VERSION = '0.02';
$VERSION = eval $VERSION;

use File::ShareDir::Install ();
use File::Spec;

our $Postamble = 1;

sub import {
  my $class = shift;
  my $caller = caller;
  my %args = ref $_[0] ? %{ shift() } : @_;

  if (defined $args{postamble}) {
    $Postamble = $args{postamble};
  };

  *MY::postamble = \&File::ShareDir::Install::postamble
    if $Postamble;

  no strict 'refs';
  *{"${caller}::with_files"} = \&with_files;
}

sub with_files ($) {
  my $input = shift;

  my $dist = $input;
  $dist =~ s/::/-/g;
  my $path = File::Spec->catdir(
    'lib', split( /-/, $dist ), 'files',
  );

  File::ShareDir::Install::install_share( $path );

  return $input;
}

1;

=head1 NAME

File::ShareDir::Install::Mojolicious

=head1 SYNOPSIS

 # Makefile.PL
 use ExtUtils::MakeMaker;
 use File::ShareDir::Install::Mojolicious;

 with_files 'MyTest::App';

 WriteMakefile(
   NAME => 'MyTest::App',
   CONFIGURE_REQUIRES => {
     'File::ShareDir::Install::Mojolicious' => 0,
     'ExtUtils::MakeMaker' => 0,
   },
   ...
 );

or chained

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

A wrapper of L<File::ShareDir::Install> for use with L<Mojolicious>. See L<Mojolicious::Plugin::FileShareDir> for more documentation.

Note that you should add it to the C<CONFIGURE_REQUIRES> key as you should for any module used in a C<Makefile.PL> file.

=head1 OPTIONS

Unless imported with the option C<< postamble => 0 >>, C<File::ShareDir::Install::postamble()> will be pushed into the C<MY> namespace. This is the most common use-case and should be done unless you know why you wouldn't.

=head1 EXPORTED FUNCTION

This module exports the function C<with_files> which takes exactly one argument, the name of the module to be installed. This then sets up the necessary information that L<File::ShareDir::Install> needs for installing the non-module content via L<File::ShareDir>.

Note that C<with_files> returns the name that was given as an argument, so that it can be inlined in the definition of C<NAME> during the call to C<WriteMakefile()> (see L</SYNOPSIS>).

=head1 SOURCE REPOSITORY

L<http://github.com/jberger/Mojolicious-Plugin-FileShareDir>

=head1 AUTHOR

Joel Berger, E<lt>joel.a.berger@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Joel Berger

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut



