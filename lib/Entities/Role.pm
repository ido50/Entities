package Entities::Role;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime qw/DateTime/;
use namespace::autoclean;

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');
has 'name' => (is => 'ro', isa => 'Str', required => 1);
has 'description' => (is => 'ro', isa => 'Str');
has 'roles' => (is => 'rw', isa => 'ArrayRef[Entities::Role]', weak_ref => 1, required => 1);
has 'actions' => (is => 'rw', isa => 'ArrayRef[Entities::Action]', weak_ref => 1, required => 1);
has 'is_super' => (is => 'ro', isa => 'Bool', required => 1);
has 'created' => (is => 'ro', isa => 'DateTime', required => 1);
has 'modified' => (is => 'ro', isa => 'DateTime', required => 1);

with 'Abilities';

around qw/roles actions/ => sub {
	my ($orig, $self) = @_;

	my $ref = $self->$orig();
	return ref $ref eq 'ARRAY' ? @$ref : $ref;
};

sub grant_action {
	my ($self, $action) = @_;

	foreach ($self->action) {
		if ($_ eq $action) {
			carp "Role ".$self->id." already has action ".$action;
			return $self;
		}
	}

	$self->actions([$self->actions, $action]);

	return $self;
}

sub inherit_from {
	my ($self, $role) = @_;

	foreach ($self->roles) {
		if ($_ eq $role) {
			carp "Role ".$self->id." already inherits from ".$role;
			return $self;
		}
	}

	$self->roles([$self->roles, $role]);

	return $self;
}

__PACKAGE__->meta->make_immutable;
1;
