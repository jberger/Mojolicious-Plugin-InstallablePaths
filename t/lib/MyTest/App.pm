package MyTest::App;
use Mojo::Base 'Mojolicious';
our @VERSION = 1;

sub startup {
  my $self = shift;
  $self->plugin( 'InstallablePaths' );
  $self->routes->any( '/' => sub{ shift->render_static('test.html') } );
}

1;

