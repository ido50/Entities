package Entities::User;

use Moose;
use namespace::autoclean;

has 'id' => (is => 'ro', isa => 'Int', required => 1);
has 'username' => (is => 'rw', isa => 'String', required => 1);
has 'realname' => (is => 'rw', isa => 'Str');
has 'roles' => (is => 'rw', isa => 'ArrayRef[Entities::Role]', weak_ref => 1, required => 1);
has 'actions' => (is => 'rw', isa => 'ArrayRef[Entities::Action]', weak_ref => 1, required => 1);
has 'is_super' => (is => 'ro', isa => 'Bool', required => 1);
has 'parent' => (is => 'ro', isa => 'Entities::Customer', weak_ref => 1, required => 1);
has 'emails' => (is => 'rw', isa => 'ArrayRef[Str]', required => 1);

with 'Abilities';

around qw/roles actions emails/ => sub {
	my ($orig, $self) = @_;

	my $ref = $self->$orig();
	return ref $ref eq 'ARRAY' ? @$ref : $ref;
};

__PACKAGE__->meta->make_immutable;
1;
