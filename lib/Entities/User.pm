package Entities::User;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime;
use MooseX::Types::Digest qw/MD5/;
use MooseX::Types::Email qw/EmailAddress/;
use Digest::MD5 qw/md5_hex/;
use namespace::autoclean;
use Carp;

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');
has 'username' => (is => 'rw', isa => 'Str', required => 1);
has 'realname' => (is => 'rw', isa => 'Str');
has 'passphrase' => (is => 'ro', isa => MD5, required => 1, writer => '_set_passphrase');
has 'roles' => (is => 'rw', isa => 'ArrayRef[Entities::Role]', default => sub { [] });
has 'actions' => (is => 'rw', isa => 'ArrayRef[Entities::Action]', default => sub { [] });
has 'is_super' => (is => 'ro', isa => 'Bool', default => 0);
has 'parent' => (is => 'ro', isa => 'Entities::Customer', weak_ref => 1, predicate => 'has_parent');
has 'emails' => (is => 'rw', isa => 'ArrayRef[Str]', default => sub { [] });
has 'created' => (is => 'ro', isa => 'DateTime', default => sub { DateTime->now() });
has 'modified' => (is => 'ro', isa => 'DateTime');

with 'Abilities';

around BUILDARGS => sub {
	my ($orig, $class, %params) = @_;

	if ($params{passphrase}) {
		$params{passphrase} = md5_hex($params{passphrase});
	}

	return $class->$orig(%params);
};

=head2 add_email

=cut

sub add_email {
	my ($self, $email) = @_;

	croak "You must provide an email address." unless $email;

	if ($self->has_email($email)) {
		carp "User ".$self->id." already has email $email";
	} else {
		my @emails = @{$self->emails};
		push(@emails, $email);
		$self->emails(\@emails);
	}

	return $self;
}

=head2 add_to_role

=cut

sub add_to_role {
	my ($self, $role) = @_;

	croak "You must provide a role name." unless $role;

	foreach (@{$self->roles}) {
		if ($_ eq $role) {
			carp "User ".$self->id." already belongs to role ".$role;
			return $self;
		}
	}

	my @roles = @{$self->roles};
	push(@roles, $role);
	$self->roles(\@roles);

	return $self;
}

=head2 grant_action

=cut

sub grant_action {
	my ($self, $action) = @_;

	croak "You must provide an action name." unless $action;

	foreach (@{$self->actions}) {
		if ($_ eq $action) {
			carp "User ".$self->id." already has action ".$action;
			return $self;
		}
	}

	my @actions = @{$self->actions};
	push(@actions, $action);
	$self->actions(\@actions);

	return $self;
}

=head2 set_passphrase

=cut

sub set_passphrase {
	my ($self, $passphrase) = @_;

	croak "You must provide a passphrase." unless $passphrase;

	$self->_set_passphrase(md5_hex($passphrase));

	return $self;
}

=head2 has_email

=cut

sub has_email {
	my ($self, $email) = @_;

	unless ($email) {
		carp "You must provide an email address.";
		return;
	}

	foreach (@{$self->emails}) {
		return 1 if $_ eq $email;
	}

	return;
}

__PACKAGE__->meta->make_immutable;
1;
