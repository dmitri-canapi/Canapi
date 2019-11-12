public class GoogleMapsGeocodeResponse {
    public Decimal latitude;
    public Decimal longitude;
    public Boolean success;
    public String message;

    public GoogleMapsGeocodeResponse(Decimal latitude, Decimal longitude, Boolean success, String message) {
        this.latitude = latitude;
        this.longitude = longitude;
        this.success = success;
        this.message = message;
    }
}