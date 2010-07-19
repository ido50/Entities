package Entities::Customer;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime;
use MooseX::Types::Email qw/EmailAddress/;
use namespace::autoclean;
use Carp;

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');
has 'name' => (is => 'ro', isa => 'Str', required => 1);
has 'email_address' => (is => 'ro', isa => EmailAddress, required => 1, writer => '_set_email_address');
has 'plans' => (is => 'rw', isa => 'ArrayRef[Entities::Plan]', predicate => 'has_plans');
has 'features' => (is => 'rw', isa => 'ArrayRef[Entities::Feature]', predicate => 'has_features');
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

	if ($self->has_direct_feature($feature_name)) {
		carp "Customer ".$self->name." already has feature $feature_name.";
		return $self;
	}

	my $feature = $self->parent->backend->get_feature($feature_name);

	croak "Feature $feature_name does not exist." unless $feature;

	my @features = $self->features;
	push(@features, $feature);
	$self->features(\@features);

	return $self;
}

=head2 add_plan

=cut

sub add_plan {
	my ($self, $plan_name) = @_;

	croak "You must provide a plan name." unless $plan_name;

	if ($self->in_plan($plan_name)) {
		carp "Customer ".$self->name." is already in plan $plan_name.";
		return $self;
	}

	my $plan = $self->parent->backend->get_plan($plan_name);

	croak "plan $plan_name does not exist." unless $plan;

	my @plans = $self->plans;
	push(@plans, $plan);
	$self->plans(\@plans);

	return $self;
}

=head2 drop_plan

=cut

sub drop_plan {
	my ($self, $plan_name) = @_;

	croak "You must provide a plan name." unless $plan_name;

	unless ($self->in_plan($plan_name)) {
		carp "Customer ".$self->name." doesn't have plan $plan_name.";
		return $self;
	}

	my @plans;
	foreach ($self->plans) {
		next if $_->name eq $plan_name;
		push(@plans, $_);
	}

	$self->plans(\@plans);

	return $self;
}

=head2 drop_feature

=cut

sub drop_feature {
	my ($self, $feature_name) = @_;

	croak "You must provide a feature name." unless $feature_name;

	unless ($self->has_direct_feature($feature_name)) {
		carp "Customer ".$self->name." doesn't have feature $feature_name.";
		return $self;
	}

	my @features;
	foreach ($self->features) {
		next if $_->name eq $feature_name;
		push(@features, $_);
	}

	$self->features(\@features);

	return $self;
}

=head2 has_direct_feature

=cut

sub has_direct_feature {
	my ($self, $feature_name) = @_;

	unless ($feature_name) {
		carp "You must provide a feature name.";
		return;
	}

	foreach ($self->features) {
		return 1 if $_->name eq $feature_name;
	}

	return;
}

__PACKAGE__->meta->make_immutable;
1;
