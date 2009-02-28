package KiokuX::Model;
use Moose;

use Carp qw(croak);

use KiokuDB;

use namespace::clean -except => 'meta';

sub BUILD {
	my $self = shift;

	$self->directory;
}

has dsn => (
    isa => "Str",
    is  => "ro",
);

has extra_args => (
    isa => "HashRef|ArrayRef",
    is  => "ro",
	predicate => "has_extra_args",
);

has typemap => (
    isa => "KiokuDB::TypeMap",
    is  => "ro",
	predicate => "has_typemap",
);

has directory => (
    isa => "KiokuDB",
    lazy_build => 1,
    handles    => 'KiokuDB::Role::API',
);

sub _build_directory {
    my $self = shift;

	KiokuDB->connect(@{ $self->_connect_args });
}

has _connect_args => (
	isa => "ArrayRef",
	is  => "ro",
	lazy_build => 1,
);

sub _build__connect_args {
    my $self = shift;

	my @args = ( $self->dsn || croak "dsn is required" );

	if ( $self->has_typemap ) {
		push @args, typemap => $self->typemap;
	}

	if ( $self->has_extra_args ) {
		my $extra = $self->extra_args;

		if ( ref($extra) eq 'ARRAY' ) {
			push @args, @$extra;
		} else {
			push @args, %$extra;
		}
	}

	\@args;
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__

=pod

=head1 NAME

KiokuX::Model - A simple application specific wrapper for L<KiokuDB>.

=head1 SYNOPSIS

	# start with the base class:

	KiokuX::Model->new( dsn => "bdb:dir=/var/myapp/db" );



	# later you can add convenience methods by subclassing:

	package MyApp::DB;
	use Moose;

	extends qw(KiokuX::Model);

	sub add_user {
		my ( $self, @args ) = @_;

		my $user = MyApp::User->new(@args);

		$self->txn_do(sub {
			$self->insert($user);
		});

		return $user;
	}

	# Then just use it like this:

	MyApp::DB->new( dsn => "bdb:dir=/var/myapp/db" );

=head1 DESCRIPTION

This base class makes it easy to create L<KiokuDB> database instances in your
application. As your app grows you can subclass it and provide additional
convenience methods.

This provides a standard way to instantiate and use a L<KiokuDB> object in your
apps.

=head1 ATTRIBUTES

=over 4

=item directory

The instantiated directory.

Created using the other attributes at C<BUILD> time.

This attribute has delegations set up for all the methods of the L<KiokuDB>
class.

=item dsn

e.g. C<bdb:dir=root/db>. See L<KiokuDB/connect>.

=item extra_args

Additional arguments to pass to C<connect>.

Can be a hash reference or an array reference.

=item typemap

An optional custom typemap to add. See L<KiokuDB::Typemap> and
L<KiokuDB/typemap>.

=back

=head1 SEE ALSO

L<Catalyst::Model::KiokuDB>

=cut
