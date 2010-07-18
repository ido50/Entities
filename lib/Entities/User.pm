package Entities::User;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime qw/DateTime/;
use MooseX::Types::Digest qw/SHA256/;
use MooseX::Types::Email qw/EmailAddress/;
use Digest::MD5 qw/md5_hex/;
use namespace::autoclean;
use Carp;

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');
has 'username' => (is => 'rw', isa => 'String', required => 1);
has 'realname' => (is => 'rw', isa => 'Str');
has 'passphrase' => (is => 'ro', isa => 'MD5', required => 1, writer => '_set_passphrase');
has 'roles' => (is => 'rw', isa => 'ArrayRef[Entities::Role]', weak_ref => 1, required => 1);
has 'actions' => (is => 'rw', isa => 'ArrayRef[Entities::Action]', weak_ref => 1, required => 1);
has 'is_super' => (is => 'ro', isa => 'Bool', required => 1);
has 'parent' => (is => 'ro', isa => 'Entities::Customer', weak_ref => 1, predicate => 'has_parent');
has 'emails' => (is => 'rw', isa => 'ArrayRef[EmailAddress]', required => 1);
has 'created' => (is => 'ro', isa => 'DateTime', required => 1);
has 'modified' => (is => 'ro', isa => 'DateTime', required => 1);

with 'Abilities';

around BUILDARGS => sub {
	my ($orig, $class, %params) = @_;

	if ($params{passphrase}) {
		$params{passphrase} = md5_hex($params{passphrase});
	}

	return $class->orig(%params);
};

around qw/roles actions emails/ => sub {
	my ($orig, $self) = @_;

	my $ref = $self->$orig();
	return ref $ref eq 'ARRAY' ? @$ref : $ref;
};

sub add_email {
	my ($self, $email) = @_;

	croak "You must provide an email address." unless $email;

	foreach ($self->emails) {
		if ($_ eq $email) {
			carp "User ".$self->id." already has email ".$email;
			return $self;
		}
	}

	$self->emails([$self->emails, $email]);

	return $self;
}

sub add_to_role {
	my ($self, $role) = @_;

	croak "You must provide a role name." unless $role;

	foreach ($self->roles) {
		if ($_ eq $role) {
			carp "User ".$self->id." already belongs to role ".$role;
			return $self;
		}
	}

	$self->roles([$self->roles, $role]);

	return $self;
}

sub grant_action {
	my ($self, $action) = @_;

	croak "You must provide an action name." unless $action;

	foreach ($self->action) {
		if ($_ eq $action) {
			carp "User ".$self->id." already has action ".$action;
			return $self;
		}
	}

	$self->actions([$self->actions, $action]);

	return $self;
}

sub set_passphrase {
	my ($self, $passphrase) = @_;

	croak "You must provide a passphrase." unless $passphrase;

	$self->_set_passphrase(md5_hex($passphrase));

	return $self;
}

__PACKAGE__->meta->make_immutable;
1;
