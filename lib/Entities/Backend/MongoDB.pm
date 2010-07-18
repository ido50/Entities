package Entities::Backend::MongoDB;

use Moose;
use namespace::autoclean;
use MongoDB;
use Carp;

extends 'Entities::Backend';

has 'host' => (is => 'ro', isa => 'Str', default => 'localhost');
has 'port' => (is => 'ro', isa => 'Int', default => 27017);
has 'db_name' => (is => 'ro', isa => 'Str', default => 'entities');
has 'db' => (is => 'rw', isa => 'MongoDB::Database');

sub BUILD {
	my $self = shift;

	my $connection = MongoDB::Connection->new(host => $self->host, port => $self->port);	
	$self->db($connection->get_database($self->db_name));
}

sub get_user_from_id {
	my ($self, $id) = @_;

	return $self->db->get_collection('users')->find_one({ _id => $id });
}

sub get_user_from_name {
	my ($self, $username) = @_;

	return $self->db->get_collection('users')->find_one({ username => $username });
}

sub get_role {
	my ($self, $name) = @_;

	return $self->db->get_collection('roles')->find_one({ name => $name });
}

sub get_customer {
	my ($self, $name) = @_;

	return $self->db->get_collection('customers')->find_one({ name => $name });
}

sub get_plan {
	my ($self, $name) = @_;

	return $self->db->get_collection('plans')->find_one({ name => $name });
}

sub get_feature {
	my ($self, $name) = @_;

	return $self->db->get_collection('features')->find_one({ name => $name });
}

sub get_action {
	my ($self, $name) = @_;

	return $self->db->get_collection('actions')->find_one({ name => $name });
}

sub save {
	my ($self, $obj) = @_;

	my $coll =	$obj->isa('Entities::User') ? 'users' :
			$obj->isa('Entities::Role') ? 'roles' :
			$obj->isa('Entities::Action') ? 'actions' :
			$obj->isa('Entities::Feature') ? 'features' :
			$obj->isa('Entities::Plan') ? 'plans' :
			$obj->isa('Entities::Customer') ? 'customers' :
			'unknown';

	croak "Can't find out the type of object received, it is not a valid Entity"
		if $coll eq 'unknown';

	if ($obj->has_id) {
		# we're updating an existing object
		croak "Failed updating the object in MongoDB collection $coll: ".$self->db->last_error
			unless $self->db->get_collection($coll)->update({ _id => $obj->id }, $self->to_hash($obj), { safe => 1 });
	} else {
		# we're storing a new object
		my $id = $self->db->get_collection($coll)->insert($self->to_hash($obj), { safe => 1 });
		croak "Failed creating the object in MongoDB collection $coll: ".$self->db->last_error
			unless $id;
		$self->_set_id($id);
	}

	return 1;
}

__PACKAGE__->meta->makeimmutable;
1;
