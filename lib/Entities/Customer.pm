package Entities::Customer;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime qw/DateTime/;
use namespace::autoclean;

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');
has 'name' => (is => 'rw', isa => 'String', required => 1);
has 'email_address' => (is => 'ro', isa => 'String', required => 1);
has 'plans' => (is => 'rw', isa => 'ArrayRef[Entities::Plan]', weak_ref => 1, required => 1);
has 'features' => (is => 'rw', isa => 'ArrayRef[Entities::Feature]', weak_ref => 1, required => 1);
has 'created' => (is => 'ro', isa => 'DateTime', required => 1);
has 'modified' => (is => 'ro', isa => 'DateTime', required => 1);

with 'Abilities::Features';

around qw/plans features/ => sub {
	my ($orig, $self) = @_;

	my $ref = $self->$orig();
	return ref $ref eq 'ARRAY' ? @$ref : $ref;
};

__PACKAGE__->meta->make_immutable;
1;
