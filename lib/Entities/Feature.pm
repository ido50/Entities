package Entities::Feature;

use Moose;
use namespace::autoclean;

has 'id' => (is => 'ro', isa => 'Int', required => 1);
has 'name' => (is => 'ro', isa => 'Str', required => 1);
has 'description' => (is => 'ro', isa => 'Str');

__PACKAGE__->meta->make_immutable;
1;
