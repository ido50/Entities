package Entities::Action;

use Moose;
use namespace::autoclean;

has 'id' => (is => 'ro', isa => 'Str', predicate => 'has_id', writer => '_set_id');
has 'name' => (is => 'ro', isa => 'Str', required => 1);
has 'description' => (is => 'ro', isa => 'Str');

__PACKAGE__->meta->make_immutable;
1;
