package Entities::Plan;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime;
use namespace::autoclean;
use Carp;

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');
has 'name' => (is => 'ro', isa => 'Str', required => 1);
has 'description' => (is => 'rw', isa => 'Str');
has 'features' => (is => 'rw', isa => 'ArrayRef[Entities::Feature]', predicate => 'has_features');
has 'plans' => (is => 'rw', isa => 'ArrayRef[Entities::Plan]', predicate => 'has_plans');
has 'created' => (is => 'ro', isa => 'DateTime', default => sub { DateTime->now() });
has 'modified' => (is => 'rw', isa => 'DateTime');
has 'parent' => (is => 'ro', isa => 'Entities', weak_ref => 1);

with 'Abilities::Features';

around qw/plans features/ => sub {
	my ($orig, $self) = (shift, shift);

	if (scalar @_) {
		return $self->$orig(@_);
	} else {
		my $ret = $self->$orig || [];
		return wantarray ? @$ret : $ret;
	}
};

=head2 add_feature

=cut

sub add_feature {
	my ($self, $feature_name) = @_;

	croak "You must provide a feature name." unless $feature_name;

	if ($self->has_feature($feature_name)) {
		carp "Plan ".$self->name." already has feature ".$feature_name;
		return $self;
	}

	# find this feature
	my $feature = $self->parent->backend->get_feature($feature_name);

	croak "feature $feature_name does not exist." unless $feature;

	my @features = $self->features;
	push(@features, $feature);
	$self->features(\@features);

	return $self;
}

=head2 take_from_plan

=cut

sub take_from_plan {
	my ($self, $plan_name) = @_;

	croak "You must provide a plan name." unless $plan_name;

	if ($self->in_plan($plan_name)) {
		carp "Plan ".$self->name." already takes from ".$plan_name;
		return $self;
	}

	# find this plan
	my $plan = $self->parent->backend->get_plan($plan_name);

	croak "plan $plan_name does not exist." unless $plan;

	my @plans = $self->plans;
	push(@plans, $plan);
	$self->plans(\@plans);

	return $self;
}

__PACKAGE__->meta->make_immutable;
1;
