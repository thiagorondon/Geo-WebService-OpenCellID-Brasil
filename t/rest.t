
use Test::More tests => 3;

use Geo::WebService::OpenCellID::Brasil;
use Cache::Memory;

my $expect = {
    "status" : "OK",
    "result" : {
        "mcc" : 724,
        "mnc" : 4,
        "lac" : 21048,
        "cid" : 11394,
        "lat" : -27.598265,
        "lon" : -48.464378,
      }
};

ok( my $model = Geo::WebService::OpenCellID::Brasil->new );

{
    ok( my $response = $model->get( 724, 4, 21048, 11394 ) );
    is_deeply( $response, $expect );
}

{
    #ok( my $cache = Cache::Memory->new );
    #is_deeply( $response, $cache->get('webraska_-23.580083_-46.642991'));
}

