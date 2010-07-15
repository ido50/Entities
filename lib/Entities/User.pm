package Entities::User;

use Moose;

has 'id' => (is => 'ro', isa => 'Int');
has 'username' => (is => 'rw', isa => 'String');
has 'realname' => (is => 'rw', isa => 'Str');
has '_roles' => (is => 'rw', isa => 'ArrayRef[Str]');
has '_actions' => (is => 'rw', isa => 'ArrayRef[Str]');
has 'is_super' => (is => 'ro', isa => 'Bool');

with 'Abilities';

sub roles {
	@{$_[0]->_roles};
}

sub actions {
	@{$_[0]->_actions};
}

no Moose;
__PACKAGE__->meta->make_immutable;
