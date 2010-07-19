package Entities::Customer;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime;
use MooseX::Types::Email qw/EmailAddress/;
use namespace::autoclean;

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');
has 'name' => (is => 'rw', isa => 'Str', required => 1);
has 'email_address' => (is => 'ro', isa => EmailAddress, required => 1);
has 'plans' => (is => 'rw', isa => 'ArrayRef[Entities::Plan]', predicate => 'has_plans');
has 'features' => (is => 'rw', isa => 'ArrayRef[Entities::Feature]', predicate => 'has_features');
has 'created' => (is => 'ro', isa => 'DateTime', default => sub { DateTime->now() });
has 'modified' => (is => 'ro', isa => 'DateTime');
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

__PACKAGE__->meta->make_immutable;
1;
