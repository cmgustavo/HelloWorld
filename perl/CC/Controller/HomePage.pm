
use strict;
use warnings;

package CC::Controller::HomePage; {
    use Moose;
    extends 'CC::Controller';
    use Apache2::Const qw(REDIRECT DECLINED NOT_FOUND OK SERVER_ERROR
        HTTP_SERVICE_UNAVAILABLE HTTP_MOVED_PERMANENTLY HTTP_MOVED_TEMPORARILY);

    use MooseX::Method::Signatures;

    method action_main {

        $self->send_html();

        return OK;
    }
}
__PACKAGE__->meta->make_immutable;
1;
