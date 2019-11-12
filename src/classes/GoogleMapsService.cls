public class GoogleMapsService {
    // Google API Key is stored in custom setting GoogleAPISettings and is editable in Salesforce Setup
    private static String GOOGLE_API_KEY = GoogleAPISettings__c.getInstance().Geocoding_API_Key__c;
    private static String GOOGLE_API_MAPS_GEOCODE_URL = 'https://maps.googleapis.com/maps/api/geocode/json';

    public static GoogleMapsGeocodeResponse geocode(String address) {
        GoogleMapsGeocodeResponse geocodeResponse;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GOOGLE_API_MAPS_GEOCODE_URL + '?address=' + EncodingUtil.urlEncode(address,'UTF-8') + '&key=' + GOOGLE_API_KEY);
        System.debug('+++ ' + request.getEndpoint());
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            geocodeResponse = parseGeocodeResponse(response.getBody());
        }
        else {
            geocodeResponse = new GoogleMapsGeocodeResponse(null, null, false, 'HTTP Status Code: ' + response.getStatusCode() + ', HTTP Status: ' + response.getStatus());
        }

        return geocodeResponse;
    }

    @TestVisible
    private static GoogleMapsGeocodeResponse parseGeocodeResponse(String responseJSON) {
        Map<String, Object> responseMap = (Map<String, Object>)System.JSON.deserializeUntyped(responseJSON);
        String status = (String)responseMap.get('status');
        
        Decimal latitude;
        Decimal longitude;
        Boolean success = false;
        String message;

        if (status == 'OK') {
            List<Object> results = (List<Object>)responseMap.get('results');
            Map<String, Object> resultsMap = (Map<String, Object>)results[0];
            Map<String, Object> geometryMap = (Map<String, Object>)resultsMap.get('geometry');
            Map<String, Object> locationMap = (Map<String, Object>)geometryMap.get('location');
            latitude = (Decimal)locationMap.get('lat');
            longitude = (Decimal)locationMap.get('lng');
            success = true;
        }
        else if (status == 'ZERO_RESULTS') {
            success = true;
        }
        else {
            success = false;
        }

        message = 'Google Maps API Status Code: ' + status;
        String errormessage = (String)responseMap.get('error_message');
        if (errormessage != null) {
            message += ', Google Maps API Error Message: ' + errormessage;
        }

        return new GoogleMapsGeocodeResponse(latitude, longitude, success, message);
    }
}