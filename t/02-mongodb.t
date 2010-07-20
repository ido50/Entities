#!perl -T

use strict;
use warnings;
use Test::More tests => 76;
use Test::Moose;
use Entities;
use Digest::MD5 qw/md5_hex/;

eval "use Entities::Backend::MongoDB";
plan skip_all => "MongoDB and Entities::Backend::MongoDB required for testing MongoDB backend." if $@;

SKIP: {
	my $bac;
	eval { $bac = Entities::Backend::MongoDB->new(db_name => 'entities_test'); };

	diag("MongoDB doesn't seem to be running.") if $@;
	skip "MongoDB doesn't seem to be running.", 76 if $@;

	ok($bac, 'Got a Memory Backend object');
	meta_ok($bac, 'Memory Backend object has meta');

	# create the Entities object, assign the backend to it, and make sure it's okay
	my $ent = Entities->new(backend => $bac);
	ok($ent, 'Got an Entities object');
	meta_ok($ent, 'Entities object has meta');
	has_attribute_ok($ent, 'backend', 'Entities object has a backend');

	# create entities to test against and make sure they're okay
	my $customer = $ent->new_customer(name => 'fooinc', email_address => 'financial@company.com');
	ok($customer, 'Created fooinc customer');
	meta_ok($customer, 'Customer fooinc object has meta');

	my $plan1 = $ent->new_plan(name => 'fooplan');
	ok($plan1, 'Created fooplan plan');
	meta_ok($plan1, 'Plan fooplan object has meta');

	my $plan2 = $ent->new_plan(name => 'barplan');
	ok($plan2, 'Created barplan plan');
	meta_ok($plan2, 'Plan barplan object has meta');

	my $feature1 = $ent->new_feature(name => 'ssh');
	ok($feature1, 'Created ssh feature');
	meta_ok($feature1, 'Feature ssh object has meta');

	my $feature2 = $ent->new_feature(name => 'backups');
	ok($feature2, 'Created backups feature');
	meta_ok($feature2, 'Feature backups object has meta');

	my $user = $ent->new_user(username => 'test_user', passphrase => 's3cr3t', customer => $customer);
	ok($user, 'Created a regular user');
	meta_ok($user, 'User object has meta');

	my $suser = $ent->new_user(username => 'super_user', passphrase => 'super_s3cr3t', is_super => 1);
	ok($suser, 'Created a super user');
	meta_ok($suser, 'Super user object has meta');

	my $role1 = $ent->new_role(name => 'foorole');
	ok($role1, 'Created foorole role');
	meta_ok($role1, 'Role foorole object has meta');

	my $role2 = $ent->new_role(name => 'barrole');
	ok($role2, 'Created barrole role');
	meta_ok($role2, 'Role barrole object has meta');

	my $act1 = $ent->new_action(name => 'do_stuff');
	ok($act1, 'Created the do_stuff action');
	meta_ok($act1, 'do_stuff has meta');

	my $act2 = $ent->new_action(name => 'do_more_stuff');
	ok($act2, 'Created the do_more_stuff action');
	meta_ok($act2, 'do_more_stuff has meta');

	my $act3 = $ent->new_action(name => 'destroy_stuff');
	ok($act3, 'Created the destroy_stuff action');
	meta_ok($act3, 'destroy_stuff has meta');

	# fill the objects with some useless crap and check every possible method
	# for every object
	$role1->grant_action('do_stuff');
	$role2->grant_action('destroy_stuff');
	$user->add_email('someone@company.com')
	     ->add_email('someone@gmail.com')
	     ->add_to_role('foorole')
	     ->grant_action('do_more_stuff');
	$plan1->add_feature('ssh');
	$plan2->add_feature('backups')
	      ->take_from_plan('fooplan');
	$customer->add_plan('fooplan');

	is($role1->has_direct_action('do_stuff'), 1, 'Role 1 explicitely granted to do_stuff');
	is($role1->has_direct_action('destroy_stuff'), undef, 'Role 1 wasn\'t granted to destroy_stuff');
	is($role2->can_perform('destroy_stuff'), 1, 'Role 2 can destroy_stuff');
	is($user->passphrase, md5_hex('s3cr3t'), 'User\'s passphrase is alright');
	is($user->has_email('someone@company.com'), 1, 'First email was indeed added');
	is($user->has_email('someone@gmail.com'), 1, 'Second email was indeed added');
	is($user->has_email('someoneelse@gmail.com'), undef, 'Unknown email indeed does not exist');
	is($user->can_perform('do_stuff'), 1, 'User can do_stuff');
	is($user->can_perform('do_more_stuff'), 1, 'User can do_more_stuff');
	is($user->can_perform('nothing'), undef, 'User can\'t perform non-existant action');
	is($user->belongs_to('foorole'), 1, 'User belongs to foorole');
	is($user->inherits_from_role('foorole'), 1, 'User inherits from foorole');
	is($user->inherits_from_role('fakerole'), undef, 'User doesn\'t inherit from fictional role');
	is($user->has_direct_action('do_more_stuff'), 1, 'User was explicitely granted to do_more_stuff');
	is($suser->can_perform('do_stuff'), 1, 'Super user can do things that exist');
	is($suser->can_perform('fictional_action'), 1, 'Super user can do things that don\'t even exist');
	is($plan1->has_feature('ssh'), 1, 'fooplan has ssh feature');
	is($plan1->has_feature('backups'), undef, 'fooplan doesn\'t have backups feature');
	is($plan2->in_plan('fooplan'), 1, 'barplan inherits from fooplan');
	is($customer->in_plan('fooplan'), 1, 'customer has fooplan');
	is($customer->has_feature('ssh'), 1, 'Customer has ssh feature');
	is($customer->has_feature('backups'), undef, 'Customer doesn\'t have backups feature');

	# now let's make some changes to the objects and make some more tests
	$customer->drop_plan('fooplan')
		 ->add_plan('barplan');
	$user->drop_role('foorole')
	     ->add_to_role('barrole')
	     ->drop_email('someone@gmail.com')
	     ->set_passphrase('other_s3cr3t');

	is($user->passphrase, md5_hex('other_s3cr3t'), 'User\'s passphrase changed.');
	is($user->has_email('someone@gmail.com'), undef, 'User no longer has someone@gmail.com email address.');
	is($user->belongs_to('foorole'), undef, 'User no longer belongs to foorole.');
	is($user->belongs_to('barrole'), 1, 'User now takes from barrole.');
	is($user->can_perform('destroy_stuff'), 1, 'User can now destory_stuff.');
	is($user->can_perform('do_stuff'), undef, 'But user can\'t do_stuff anymore.');
	is($customer->in_plan('fooplan'), undef, 'Customer no longer has fooplan.');
	is($customer->in_plan('barplan'), 1, 'Customer now has barplan.');
	is($customer->inherits_from_plan('fooplan'), 1, 'But customer still takes from fooplan.');
	is($customer->has_feature('backups'), 1, 'Customer now has backups feature.');
	is($customer->has_feature('ssh'), 1, 'Customer still has the ssh feature.');

	# let's make some more changes yet again
	$role2->inherit_from_role('foorole');
	$user->drop_action('do_more_stuff');
	$plan1->add_feature('backups');
	$customer->add_feature('ssh');

	is($role2->takes_from('foorole'), 1, 'barrole directly inherits from foorole');
	is($role2->inherits_from_role('foorole'), 1, 'barrole inherits from foorole');
	is($role2->can_perform('do_stuff'), 1, 'barrole can no longer do_stuff');
	is($user->has_direct_action('do_more_stuff'), undef, 'User was not explicitely granted to do_more_stuff');
	is($user->can_perform('do_more_stuff'), undef, 'User can no longer do_more_stuff');
	is($plan1->has_direct_feature('backups'), 1, 'fooplan now has backups');
	is($plan2->inherits_from_plan('fooplan'), 1, 'barplan still inherits from fooplan');
	is($customer->has_direct_feature('ssh'), 1, 'customer was explicitely given ssh feature');

	# final time
	$role2->drop_action('destroy_stuff')
	      ->dont_inherit_from_role('foorole');
	$plan1->drop_feature('backups');
	$plan2->dont_take_from_plan('fooplan');
	$customer->drop_feature('ssh');

	is($role2->can_perform('destroy_stuff'), undef, 'barrole cannot destory_stuff anymore');
	diag($user->all_abilities);	
	is($user->can_perform('destroy_stuff'), undef, 'so does user');
	is($role2->inherits_from_role('foorole'), undef, 'barrole no longer inherits from foorole');
	is($plan1->has_feature('backups'), undef, 'fooplan no longer has backups feature');
	is($plan2->inherits_from_plan('fooplan'), undef, 'barplan no longer inherits from fooplan');
	is($customer->has_direct_feature('ssh'), undef, 'customer no longer has explicit ssh feature');
}

done_testing();
