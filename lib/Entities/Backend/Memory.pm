package Entities::Backend::Memory;

use Moose;
use namespace::autoclean;
use Carp;

extends 'Entities::Backend';

has 'roles' => (is => 'rw', isa => 'ArrayRef[Entities::Role]');
has 'users' => (is => 'rw', isa => 'ArrayRef[Entities::User]');
has 'actions' => (is => 'rw', isa => 'ArrayRef[Entities::Action]');
has 'plans' => (is => 'rw', isa => 'ArrayRef[Entities::Plan]');
has 'customers' => (is => 'rw', isa => 'ArrayRef[Entities::Customer]');
has 'features' => (is => 'rw', isa => 'ArrayRef[Entities::Feature]');

=head2 get_user_from_id

=cut

sub get_user_from_id {
	my ($self, $id) = @_;

	foreach (@{$self->users}) {
		return $_ if $_->id == $id;
	}

	return;
}

=head2 get_user_from_name

=cut

sub get_user_from_name {
	my ($self, $username) = @_;

	foreach (@{$self->users}) {
		return $_ if $_->username eq $username;
	}

	return;
}

=head2 get_role

=cut

sub get_role {
	my ($self, $name) = @_;

	foreach (@{$self->roles}) {
		return $_ if $_->name eq $name;
	}

	return;
}

=head2 get_customer

=cut

sub get_customer {
	my ($self, $name) = @_;

	foreach (@{$self->customers}) {
		return $_ if $_->name eq $name;
	}

	return;
}

=head2 get_plan

=cut

sub get_plan {
	my ($self, $name) = @_;

	foreach (@{$self->plans}) {
		return $_ if $_->name eq $name;
	}

	return;
}

=head2 get_feature

=cut

sub get_feature {
	my ($self, $name) = @_;

	foreach (@{$self->features}) {
		return $_ if $_->name eq $name;
	}

	return;
}

=head2 get_action

=cut

sub get_action {
	my ($self, $name) = @_;

	foreach (@{$self->actions}) {
		return $_ if $_->name eq $name;
	}

	return;
}

=head2 save

=cut

sub save {
	my ($self, $obj) = @_;

	unless ($obj->has_id) {
		my $coll =	$obj->isa('Entities::User') ? 'users' :
				$obj->isa('Entities::Role') ? 'roles' :
				$obj->isa('Entities::Action') ? 'actions' :
				$obj->isa('Entities::Feature') ? 'features' :
				$obj->isa('Entities::Plan') ? 'plans' :
				$obj->isa('Entities::Customer') ? 'customers' :
				'unknown';

		croak "Can't find out the type of object received, it is not a valid Entity"
			if $coll eq 'unknown';

		my $array = $self->$coll;
		$obj->_set_id(scalar @$array + 1);
		push(@$array, $obj);
		$self->$coll($array);
	}

	return 1;
}

__PACKAGE__->meta->make_immutable;
1;
