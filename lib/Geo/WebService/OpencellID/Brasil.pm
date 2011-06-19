
package Geo::WebService::OpenCellID::Brasil;

use Moose;
use LWP::UserAgent;
use JSON;

# ABSTRACT: WebService to get address from lat/long based on webraska.
# VERSION

has url => (
    is      => 'rw',
    isa     => 'Str',
    default => 'http://api.opencellid.com.br/v1/cellsite/%s/%s/%s/%s'
);

has ua => (
    is       => 'ro',
    isa      => 'Object',
    init_arg => undef,
    lazy     => 1,
    default  => sub { LWP::UserAgent->new }
);

has cache => (
    is        => 'ro',
    isa       => 'Object',
    predicate => 'has_cache',
);

sub _request_url {
    my ( $self, $mcc, $mnc, $lac, $cid ) = @_;
    my $url = sprintf( $self->url, $mcc, $mnc, $lac, $cid );
    warn $url;
    return $url;
}
sub _get_http {
    my ( $self, $url ) = @_;
    return $self->ua->get($url);
}

sub _post_http {
    my ( $self, $url ) = @_;
    return $self->ua->post($url);
}

sub _getinfofromjson {
    my ( $self, $content ) = @_;
    warn $content;
    return from_json($content);
}

sub _set_cache {
    my ( $self, $key, $value ) = @_;
    $self->cache->set( $key, $value );
}

sub _get_cache {
    my ( $self, $key ) = @_;
    $self->cache->get($key);
}

sub _make_key {
    my ($self, @args) = @_;
    return join('_', 'ocib', @args);
}

sub get {
    my ( $self, $mcc, $mnc, $lac, $cid ) = @_;

    my ( $res, $key );
    if ( $self->has_cache ) {
        $key = $self->_make_key( $mcc, $mnc, $lac, $cid );
        $res = $self->_get_cache($key);
        return $res if $res;
    }

    my $url = $self->_request_url( $mcc, $mnc, $lac, $cid );
    $res = $self->_get_http($url);
    my $response = $self->_getinfofromjson($res->content);

    $self->_set_cache( $key, $response ) if $self->has_cache;

    return $response;

}

sub post {
    my ( $self, $mcc, $mnc, $lac, $cid ) = @_;
    my $url = $self->_request_url( $mcc, $mnc, $lac, $cid );
    my $res = $self->_post_http($url);
    my $response = $self->_getinfofromjson($res->content);
    return $response->{status} eq 'OK' ? 1 : 0;
}

1;

