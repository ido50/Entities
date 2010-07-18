#!perl -T

use strict;
use warnings;
use Test::More;
use Test::Moose;
use Entities;
use Entities::Backend::Memory;

my $ent = Entities->new(backend => Entities::Backend::Memory->new);

ok($ent, 'Got an Entities object');
meta_ok($ent, 'Entities object has meta');
has_attribute_ok($ent, 'backend', 'Entities object has a backend');

# create a customer
my $customer = $ent->new_customer(name => 'Test Customer', email_address => 'financial@company.com');
ok($customer, 'Created a customer');
meta_ok($customer, 'Customer object has meta');

my $plan = $ent->new_plan(name => 'Test Plan', description => 'This is nothing but a test plan.');
ok($plan, 'Created a plan');
meta_ok($plan, 'Plan object has meta');

my $feature = $ent->new_feature(name => 'Test Feature');
ok($feature, 'Created a feature');
meta_ok($feature, 'Feature object has meta');

my $user = $ent->new_user(username => 'test_user', passphrase => 's3cr3t', customer => $customer);
ok($user, 'Created a regular user');
meta_ok($user, 'User object has meta');

my $suser = $ent->new_user(username => 'super_user', passphrase => 'super_s3cr3t', is_super => 1);
ok($suser, 'Created a super user');
meta_ok($suser, 'Super user object has meta');

my $role = $ent->new_role(name => 'Test Role');
ok($role, 'Created a role');
meta_ok($role, 'Role object has meta');

my $act_one = $ent->new_action(name => 'do_stuff');
ok($act_one, 'Created the do_stuff action');
meta_ok($act_one, 'do_stuff has meta');

my $act_two = $ent->new_action(name => 'do_more_stuff');
ok($act_two, 'Created the do_more_stuff action');
meta_ok($act_two, 'do_more_stuff has meta');

# add some stuff to this user
$user->add_email('someone@company.com')
     ->add_email('someone@gmail.com')
     #->add_to_role('Test Role')
     #->grant_action('do_stuff')
     ->set_passphrase('new_s3cr3t');

is($user->has_email('someone@company.com'), 1, 'First email was indeed added');
is($user->has_email('someone@gmail.com'), 1, 'Second email was indeed added');
is($user->has_email('someoneelse@gmail.com'), undef, 'Unknown email indeed does not exist');

done_testing();
