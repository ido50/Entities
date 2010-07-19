package Entities::Role;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime;
use namespace::autoclean;
use Carp;

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');
has 'name' => (is => 'ro', isa => 'Str', required => 1);
has 'description' => (is => 'ro', isa => 'Str');
has 'roles' => (is => 'rw', isa => 'ArrayRef[Entities::Role]', predicate => 'has_roles');
has 'actions' => (is => 'rw', isa => 'ArrayRef[Entities::Action]', predicate => 'has_actions');
has 'is_super' => (is => 'ro', isa => 'Bool', default => 0);
has 'created' => (is => 'ro', isa => 'DateTime', default => sub { DateTime->now() });
has 'modified' => (is => 'ro', isa => 'DateTime');
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

=head2 grant_action

=cut

sub grant_action {
	my ($self, $action) = @_;

	foreach ($self->actions) {
		if ($_ eq $action) {
			carp "Role ".$self->id." already has action ".$action;
			return $self;
		}
	}

	my @actions = $self->actions;
	push(@actions, $action);
	$self->actions(\@actions);

	return $self;
}

=head2 inherit_from

=cut

sub inherit_from {
	my ($self, $role) = @_;

	foreach ($self->roles) {
		if ($_ eq $role) {
			carp "Role ".$self->id." already inherits from ".$role;
			return $self;
		}
	}

	my @roles = @{$self->roles};
	push(@roles, $role);
	$self->roles(\@roles);

	return $self;
}

__PACKAGE__->meta->make_immutable;
1;
