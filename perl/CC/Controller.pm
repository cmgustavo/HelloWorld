use strict;
use warnings;

package CC::Controller; {    
    use Moose;
    extends 'NC::Controller';
    
    sub BUILD {
        my $self = shift;
    }    

}
__PACKAGE__->meta->make_immutable;
1;
