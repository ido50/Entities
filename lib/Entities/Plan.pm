package Entities::Plan;

use Moose;
use namespace::autoclean;

has 'id' => (is => 'ro', isa => 'Int', required => 1);
has 'name' => (is => 'rw', isa => 'String', required => 1);
has 'description' => (is => 'rw', isa => 'String');
has 'features' => (is => 'rw', isa => 'ArrayRef[Entities::Feature]', weak_ref => 1, required => 1);
has 'plans' => (is => 'rw', isa => 'ArrayRef[Entities::Plan]', weak_ref => 1, required => 1);

with 'Abilities::Features';

around qw/plans features/ => sub {
	my ($orig, $self) = @_;

	my $ref = $self->$orig();
	return ref $ref eq 'ARRAY' ? @$ref : $ref;
};

__PACKAGE__->meta->make_immutable;
1;
