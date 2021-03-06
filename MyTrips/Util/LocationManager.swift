import Foundation
import GooglePlaces
import GoogleMaps

//Should rename this class, its confusing and redundant with one that exists inthe google sdk
class LocationManager {
    
    static func getLocationBounds(_ locationCoordinate: CLLocationCoordinate2D) -> GMSCoordinateBounds{
        //add some more math in here to calculate dynamic distance with greater accuracy (ie. take in quantity and
        //convert distance to degree
        //I think the .5 degree measurement gets somewhat close to a 50 mile radius
        let eastLong = locationCoordinate.longitude + 0.5
        let northLat = locationCoordinate.latitude + 0.5
        let northEastCorner = CLLocationCoordinate2D.init(latitude: northLat, longitude: eastLong)
        let westLong = locationCoordinate.longitude - 0.5
        let southLat = locationCoordinate.latitude - 0.5
        let southWestCorner = CLLocationCoordinate2D.init(latitude: southLat, longitude: westLong)
        
        return GMSCoordinateBounds.init(coordinate: southWestCorner, coordinate: northEastCorner)
    }
    
    //TODO: create function that will actually tell us what the radius or distance of the map is...
    //Convert lattitude and longitude to distance?
    
    static func getLocationBoundsFromMap(map: GMSMapView) -> GMSCoordinateBounds {
        let projection = map.projection.visibleRegion()
        let southwestBound = projection.nearLeft
        let northeastBound = projection.farRight
        let coordinateBounds = GMSCoordinateBounds.init(coordinate: southwestBound, coordinate: northeastBound)
        return coordinateBounds
    }
}
