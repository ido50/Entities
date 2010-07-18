package Entities::Customer;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::DateTime;
use MooseX::Types::Email qw/EmailAddress/;
use namespace::autoclean;

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');
has 'name' => (is => 'rw', isa => 'Str', required => 1);
has 'email_address' => (is => 'ro', isa => EmailAddress, required => 1);
has 'plans' => (is => 'rw', isa => 'ArrayRef[Entities::Plan]', weak_ref => 1, predicate => 'has_plans', default => sub { [] });
has 'features' => (is => 'rw', isa => 'ArrayRef[Entities::Feature]', weak_ref => 1, predicate => 'has_features', default => sub { [] });
has 'created' => (is => 'ro', isa => 'DateTime', default => sub { DateTime->now() });
has 'modified' => (is => 'ro', isa => 'DateTime');

with 'Abilities::Features';

__PACKAGE__->meta->make_immutable;
1;
