package Entities::Backend;

use Moose::Role;
use namespace::autoclean;

requires 'get_user_from_id';
requires 'get_user_from_name';
requires 'get_role';
requires 'get_action';
requires 'get_plan';
requires 'get_feature';
requires 'get_customer';
requires 'save';

1;
