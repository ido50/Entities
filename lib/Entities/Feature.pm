package Entities::Feature;

use Moose;
use namespace::autoclean;

# ABSTRACT: A certain functionality, or just plan feature, that customers can use.

=head1 NAME

Entities::Feature - A certain functionality, or just plan feature, that customers can use.

=head1 SYNOPSIS

	used internally, see L<Entities>

=head1 DESCRIPTION

A feature is just a name for some functionality or feature in your
webapp, that you want to limit the availability of to certain privileged
customers only. A feature is the basis of L<feature-based authorization|Abilities::Features>.

NOTE: you are not meant to create feature objects directly, but only through
the C<new_feature()> method in L<Entities>.

=head1 METHODS

=head2 new( name => 'somefeature', [ description => 'Just some feature',
parent => $entities_obj, id => 123 ] )

Creates a new instance of this module. Only 'name' is required.

=head2 id()

Returns the ID of the feature, if set.

=head2 has_id()

Returns a true value if the feature has an ID attribute.

=head2 _set_id( $id )

Changes the ID of the feature object to a new ID. Should only be used
internally.

=cut

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');

=head2 name()

Returns the name of the feature.

=cut

has 'name' => (is => 'ro', isa => 'Str', required => 1);

=head2 description( [$new_description] )

Returns the description text of the feature. If a new description is provided,
it is set as the feature's description.

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

    perldoc Entities::Feature

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
