@isTest
public class GoogleMapsServiceTest {
    @isTest
    private static void parseGeocodeResponseOkTest() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'GoogleMapsAPIGeocodeResponseOK' LIMIT 1];
        String responseJSON = sr.Body.toString();

        Test.startTest();
        GoogleMapsGeocodeResponse geocodeResponse = GoogleMapsService.parseGeocodeResponse(responseJSON);
        Test.stopTest();

        System.assert(geocodeResponse != null);
        System.assert(geocodeResponse.success);
        System.assert(geocodeResponse.latitude != null);
        System.assert(geocodeResponse.longitude != null);
    }

    @isTest
    private static void parseGeocodeResponseZeroResultsTest() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'GoogleMapsAPIGeocodeResponseZERO_RESULTS' LIMIT 1];
        String responseJSON = sr.Body.toString();

        Test.startTest();
        GoogleMapsGeocodeResponse geocodeResponse = GoogleMapsService.parseGeocodeResponse(responseJSON);
        Test.stopTest();

        System.assert(geocodeResponse != null);
        System.assert(geocodeResponse.success);
        System.assert(geocodeResponse.latitude == null);
        System.assert(geocodeResponse.longitude == null);
    }

    @isTest
    private static void parseGeocodeResponseOverQueryLimitTest() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'GoogleMapsAPIGeocodeResponseOVER_QUERY_LIMIT' LIMIT 1];
        String responseJSON = sr.Body.toString();

        Test.startTest();
        GoogleMapsGeocodeResponse geocodeResponse = GoogleMapsService.parseGeocodeResponse(responseJSON);
        Test.stopTest();

        System.assert(geocodeResponse != null);
        System.assert(!geocodeResponse.success);
        System.assert(geocodeResponse.latitude == null);
        System.assert(geocodeResponse.longitude == null);
    }

    @isTest
    private static void geocodeCalloutSuccessTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GoogleMapsAPIGeocodeResponseOK');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        
        GoogleMapsGeocodeResponse geocodeResponse = GoogleMapsService.geocode('1600 Amphitheatre Parkway, Mountain View, CA 94043, USA');

        Test.stopTest();

        System.assert(geocodeResponse != null);
        System.assert(geocodeResponse.success);
        System.assert(geocodeResponse.latitude != null);
        System.assert(geocodeResponse.longitude != null);
    }

    @isTest
    private static void geocodeCalloutFailureTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GoogleMapsAPIGeocodeResponseOK');
        mock.setStatusCode(500);
        mock.setStatus('Server Error');
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        
        GoogleMapsGeocodeResponse geocodeResponse = GoogleMapsService.geocode('1600 Amphitheatre Parkway, Mountain View, CA 94043, USA');

        Test.stopTest();

        System.assert(geocodeResponse != null);
        System.assert(!geocodeResponse.success);
        System.assert(geocodeResponse.latitude == null);
        System.assert(geocodeResponse.longitude == null);
    }
}