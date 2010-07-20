package Entities::Action;

use Moose;
use namespace::autoclean;

# ABSTRACT: A piece of code/functionality that a user entity can perform.

=head1 NAME

Entities::Action - A piece of code/functionality that a user entity can perform.

=head1 SYNOPSIS

	used internally, see L<Entities>

=head1 DESCRIPTION

An action is just a name for a piece of code or some functionality in your
code, that you want to limit the availability of to certain privileged
users only. An action is the basis of L<ability-based authorization|Abilities>.

NOTE: you are not meant to create action objects directly, but only through
the C<new_action()> method in L<Entities>.

=head1 METHODS

=head2 new( name => 'someaction', [ description => 'Just some action',
parent => $entities_obj, id => 123 ] )

Creates a new instance of this module. Only 'name' is required.

=head2 id()

Returns the ID of the action, if set.

=head2 has_id()

Returns a true value if the action has an ID attribute.

=head2 _set_id( $id )

Changes the ID of the action object to a new ID. Should only be used
internally.

=cut

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');

=head2 name()

Returns the name of the action.

=cut

has 'name' => (is => 'ro', isa => 'Str', required => 1);

=head2 description( [$new_description] )

Returns the description text of the action. If a new description is provided,
it will be set as the action's description.

=cut

has 'description' => (is => 'rw', isa => 'Str');

=head2 parent()

Returns the L<Entities> instance that controls this object.

=cut

has 'parent' => (is => 'ro', isa => 'Entities', weak_ref => 1);

=head1 SEE ALSO

L<Entities>.

=head1 AUTHOR

Ido Perlmuter, C<< <ido at ido50 dot net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-entities at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Entities>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Entities::Action

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
