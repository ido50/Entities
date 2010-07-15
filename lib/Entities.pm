package Entities;

use warnings;
use strict;

# ABSTRACT: User management and authorization for web applications and subscription-based services.

=head1 NAME

Entities - User management and authorization for web applications and subscription-based services.

=head1 SYNOPSIS

	use Entities;

	# create a new Entities object, with a MongoDB backend
	my $ent = Entities->new(backend => 'MongoDB');

	# create a new role
	my $role = $ent->add_rule(name => 'members');
	$role->give_action('make_mess')
	     ->inherit_from('limited_members');

	# create a new user
	my $user = $ent->add_user(username => 'someone');
	$user->add_email('someone@someplace.com')
	     ->add_to_role('members');
	     ->give_action('do_stuff');

	# check user can do stuff
	if ($user->can_perform('do_stuff')) {
		&do_stuff();
	} else {
		croak "Listen, you just can't do that. C'mon.";
	}

=head1 DESCRIPTION

This module does shit.

=head1 METHODS

=head1 AUTHOR

Ido Perlmuter, C<< <ido at ido50.net> >>

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

1;
