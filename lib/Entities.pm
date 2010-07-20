package Entities;

use Moose;
use namespace::autoclean;

use Entities::User;
use Entities::Role;
use Entities::Action;
use Entities::Customer;
use Entities::Plan;
use Entities::Feature;

has 'backend' => (is => 'ro', does => 'Entities::Backend', required => 1);

# ABSTRACT: User management and authorization for web applications and subscription-based services.

=head1 NAME

Entities - User management and authorization for web applications and subscription-based services.

=head1 SYNOPSIS

	use Entities;

	# create a new Entities object, with a MongoDB backend
	my $ent = Entities->new(backend => 'MongoDB');

	# create a new role
	my $role = $ent->new_role(name => 'members');
	$role->grant_action('make_mess')
	     ->inherit_from('limited_members');

	# create a new user
	my $user = $ent->new_user(username => 'someone');
	$user->add_email('someone@someplace.com')
	     ->add_to_role('members');
	     ->grant_action('stuff');

	# check user can do stuff
	if ($user->can_perform('stuff')) {
		&do_stuff();
	} else {
		croak "Listen, you just can't do that. C'mon.";
	}

=head1 DESCRIPTION

Entities is a complete system of user management and authorization for
web applications and subscription-based web services, implementing what
I call 'ability-based authorization', as defined by L<Abilities> and
L<Abilities::Features>.

This is a reference implementation, meant to be both extensive enough to
be used by web applications, and to serve as an example of how to use and
create ability-based authorization systems.

=head2 ENTITIES?

Ability-based authorization deals with six types of "entities":

=over

=item * Customers (represented by L<Entities::Customer>

A customer is an abstract entity that merely serves to unify the people
who are actually using your app (see "users"). It can either be a person,
a company, an organization or whatever. Basically, the customer is the
"body" that signed up for your service and possibly is paying for it. A
customer can have 1 or more users.

=item * Users (represented by L<Entities::User>

A user is a person that belongs to a certain company and has received
access to your app. They are the actual entities that are interacting with
your application, not their parent entities (i.e. customers). Users have
the ability to perform actions (see later), probably only within their
parent entity's scope (see L</"SCOPING">) and maybe to a certain limit
(see L</"LIMITING">).

=item * Plans (represented by L<Entities::Plan>)

A plan is a group of features (see "features"), with certain limits and
scoping restrictions, that customers subscribe to. You are probably familiar
with this concept from web services you use (like GitHub, Google Apps, etc.).

A customer can subscribe to one or more plans (plans do not have to be
related in any way), so that users of that customer can use the features
provided with those plans.

=item * Features (represented by L<Entities::Feature>)

A feature is also an abstract entity used to define "something" that customers
can use on your web service. Perhaps "SSL Encryption" is a feature provided
with some (but not all) of your plans. Or maybe "Opening Blogs" is a feature
of all your plans, with different limits set on this feature for every plan.

In other words, features are as they're named: the features of your app.
It's your decision who gets to use them.

=item * Actions (represented by L<Entities::Actions>)

Actions are the core of 'ability-based authorization'. They define the
actual activities that users can perform inside your app. For example,
'creating a new blog post' is an action that a user can perform. Another
example would be 'approving comments'. Maybe even 'creating new users'.

Actions, therefore, are units of "work" you define in your code. Users will
be able to perform such unit of work only if they are granted with the 'ability'
to perform the action the defines it, and only if this action is within
the defined 'scope' and 'limit' of the parent customer. A certain ability
can be bestowed upon a user either explicitly, or via roles (see below).

=item * Roles (represented by L<Entities::Role>)

Roles might be familiar to you from 'role-based authorization'. Figuratively
speaking, they are 'masks' that users can wear. A role is nothing but a
group of actions. When a user is assigned a certain role, they consume
all the actions defined in that role, and therefore the user is able to
perform it. You will most likely find yourself creating roles such as
'admins', 'members', 'guests', etc.

Roles are self-inheriting, i.e. a role can inherit the actions of another
role.

=back

=head2 SCOPING

=head2 LIMITING

=head1 METHODS

=head2 new( backend => $backend )

Creates a new instance of the Entities module. Requires a backend object
to be used for storage (see L<Entities::Backend> for more information
and a list of currently available backends).

=head2 new_role( name => 'somerole', [ description => 'Just some role',
is_super => 0, roles => [], actions => [], created => $dt_obj,
modified => $other_dt_obj, parent => $entities_obj, id => 123 ] )

Creates a new L<Entities::Role> object, stores it in the backend and
returns it.

=cut

sub new_role {
	my $self = shift;

	return Entities::Role->new(@_);
}

=head2 new_user( username => 'someguy', passphrase => 's3cr3t', [ realname => 'Some Guy',
is_super => 0, roles => [], actions => [], customer => $customer_obj, id => 123,
emails => [], created => $dt_obj, modified => $other_dt_obj, parent => $entities_obj ] )

Creates a new L<Entities::User> object, stores it in the backend and
returns it.

=cut

sub new_user {
	my $self = shift;

	return Entities::User->new(@_);
}

=head2 new_action( name => 'someaction', [ description => 'Just some action',
parent => $entities_obj, id => 123 ] )

Creates a new L<Entities::Action> object, stores it in the backend and
returns it.

=cut

sub new_action {
	my $self = shift;

	return Entities::Action->new(@_);
}

=head2 new_plan( name => 'someplan', [ description => 'Just some plan',
features => [], plans => [], created => $dt_obj, modified => $other_dt_obj,
parent => $entities_obj, id => 123 ] )

Creates a new L<Entities::Plan> object, stores it in the backend and
returns it.

=cut

sub new_plan {
	my $self = shift;

	return Entities::Plan->new(@_);
}

=head2 new_feature( name => 'somefeature', [ description => 'Just some feature',
parent => $entities_obj, id => 123 ] )

Creates a new L<Entities::Feature> object, stores it in the backend
and returns it.

=cut

sub new_feature {
	my $self = shift;

	return Entities::Feature->new(@_);
}

=head2 new_customer( name => 'somecustomer', email_address => 'customer@customer.com',
[ features => [], plans => [], created => $dt_obj, modified => $other_dt_obj,
parent => $entities_obj, id => 123 ] )

Creates a new L<Entities::Customer> object, stores it in the backend
and returns it.

=cut

sub new_customer {
	my $self = shift;

	return Entities::Customer->new(@_);
}

=head1 METHOD MODIFIERS

The following list documents any method modifications performed through
the magic of L<Moose>.

=head2 around qr/^new_.+$/

This method modifier is used when any of the above C<new_something> methods
are invoked. It is used to automatically pass the Entities object to the
newly created object (as the 'parent' attribute), and to automatically
save the object in the backend.

=cut

around qr/^new_.+$/ => sub {
	my ($orig, $self) = (shift, shift);

	push(@_, parent => $self->backend);

	my $obj = $self->$orig(@_);

	$self->backend->save($obj);

	return $obj;
};

=head1 SEE ALSO

L<Abilities>, L<Abilities::Features>, L<Catalyst::Authentication::Abilities>.

=head1 AUTHOR

Ido Perlmuter, C<< <ido at ido50 dot net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-entities at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Entities>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Entities

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Entities>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Entities>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Entities>

=item * Search CPAN

L<http://search.cpan.org/dist/Entities/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Ido Perlmuter.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

__PACKAGE__->meta->make_immutable;
1;
