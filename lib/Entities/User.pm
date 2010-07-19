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
has 'roles' => (is => 'rw', isa => 'ArrayRef[Entities::Role]', predicate => 'has_roles');
has 'actions' => (is => 'rw', isa => 'ArrayRef[Entities::Action]', predicate => 'has_actions');
has 'is_super' => (is => 'ro', isa => 'Bool', default => 0);
has 'customer' => (is => 'ro', isa => 'Entities::Customer', weak_ref => 1, predicate => 'has_customer');
has 'emails' => (is => 'rw', isa => 'ArrayRef[Str]', predicate => 'has_emails');
has 'created' => (is => 'ro', isa => 'DateTime', default => sub { DateTime->now() });
has 'modified' => (is => 'ro', isa => 'DateTime');
has 'parent' => (is => 'ro', isa => 'Entities', weak_ref => 1);

with 'Abilities';

around qw/roles actions emails/ => sub {
	my ($orig, $self) = (shift, shift);

	if (scalar @_) {
		return $self->$orig(@_);
	} else {
		my $ret = $self->$orig || [];
		return wantarray ? @$ret : $ret;
	}
};

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
	my ($self, $role_name) = @_;

	croak "You must provide a role name." unless $role_name;

	foreach ($self->roles) {
		next unless $_->name eq $role_name;
		carp "User ".$self->id." already belongs to role ".$role_name;
		return $self;
	}

	# find this role
	my $role = $self->parent->backend->get_role($role_name);

	croak "Role $role_name does not exist." unless $role;

	my @roles = $self->roles;
	push(@roles, $role);
	$self->roles(\@roles);

	return $self;
}

=head2 grant_action

=cut

sub grant_action {
	my ($self, $action_name) = @_;

	croak "You must provide an action name." unless $action_name;

	foreach ($self->actions) {
		next unless $_->name eq $action_name;
		carp "User ".$self->id." already has action ".$action_name;
		return $self;
	}

	# find this action
	my $action = $self->parent->backend->get_action($action_name);
	
	croak "Action $action_name does not exist." unless $action;

	my @actions = $self->actions;
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

	foreach ($self->emails) {
		return 1 if $_ eq $email;
	}

	return;
}

__PACKAGE__->meta->make_immutable;
1;
