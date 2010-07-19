package Entities::Role;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime;
use namespace::autoclean;
use Carp;

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');
has 'name' => (is => 'ro', isa => 'Str', required => 1);
has 'description' => (is => 'rw', isa => 'Str');
has 'roles' => (is => 'rw', isa => 'ArrayRef[Entities::Role]', predicate => 'has_roles');
has 'actions' => (is => 'rw', isa => 'ArrayRef[Entities::Action]', predicate => 'has_actions');
has 'is_super' => (is => 'ro', isa => 'Bool', default => 0);
has 'created' => (is => 'ro', isa => 'DateTime', default => sub { DateTime->now() });
has 'modified' => (is => 'rw', isa => 'DateTime');
has 'parent' => (is => 'ro', isa => 'Entities', weak_ref => 1);

with 'Abilities';

around qw/roles actions/ => sub {
	my ($orig, $self) = (shift, shift);

	if (scalar @_) {
		return $self->$orig(@_);
	} else {
		my $ret = $self->$orig || [];
		return wantarray ? @$ret : $ret;
	}
};

=head2 has_direct_action

=cut

sub has_direct_action {
	my ($self, $action_name) = @_;

	unless ($action_name) {
		carp "You must provide an action name.";
		return;
	}

	foreach ($self->actions) {
		return 1 if $_->name eq $action_name;
	}

	return;
}

=head2 grant_action

=cut

sub grant_action {
	my ($self, $action_name) = @_;

	croak "You must provide an action name." unless $action_name;

	if ($self->has_direct_action($action_name)) {
		carp "Role ".$self->id." already has action ".$action_name;
		return $self;
	}

	# find this action
	my $action = $self->parent->backend->get_action($action_name);
	croak "Action $action_name does not exist." unless $action;

	my @actions = $self->actions;
	push(@actions, $action);
	$self->actions(\@actions);

	return $self;
}

=head2 inherit_from_role

=cut

sub inherit_from_role {
	my ($self, $role_name) = @_;

	croak "You must provide a role name." unless $role_name;

	if ($self->takes_from($role_name)) {
		carp "Role ".$self->id." already inherits from ".$role_name;
		return $self;
	}

	# find this action
	my $role = $self->parent->backend->get_role($role_name);
	croak "Role $role_name does not exist." unless $role;

	my @roles = $self->roles;
	push(@roles, $role);
	$self->roles(\@roles);

	return $self;
}

__PACKAGE__->meta->make_immutable;
1;
