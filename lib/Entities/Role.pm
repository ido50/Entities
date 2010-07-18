package Entities::Role;

use Moose;
use namespace::autoclean;

has 'id' => (is => 'ro', isa => 'Int', required => 1);
has 'name' => (is => 'ro', isa => 'Str', required => 1);
has 'description' => (is => 'ro', isa => 'Str');
has 'roles' => (is => 'rw', isa => 'ArrayRef[Entities::Role]', weak_ref => 1, required => 1);
has 'actions' => (is => 'rw', isa => 'ArrayRef[Entities::Action]', weak_ref => 1, required => 1);

with 'Abilities';

around qw/roles actions/ => sub {
	my ($orig, $self) = @_;

	my $ref = $self->$orig();
	return ref $ref eq 'ARRAY' ? @$ref : $ref;
};

__PACKAGE__->meta->make_immutable;
1;
