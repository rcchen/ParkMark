### ParkMark - Pom Finds Parked Car

The premise of this project is pretty simple: I forget where I leave my car every time I need to
be in downtown Palo Alto for longer than two hours, and would like my phone to give me directions 
to where my car is. Yes, it is possible to put pins on maps and whatnot, but the experience sucks.
This project makes it very straightforward to find your parked car.

#### Instructions 

1) Let the app get your location.
2) Hit "Start" to set your current parking spot. Use the "Get Location" button to get your
location. This button can be used throughout the application, so use it liberally, it is useful.
3) Hit "Find Car" to get directions to your car. If you close the dialog by accident, a wild 
button that says "Show Directions" will have magically appeared, and you can use that.
4) Hit "Finish" when you are done.

#### Caveats

To run this project, you will have to use a device that supports LocationServices. I strongly
recommend that you only attempt to use this on an iPhone as relying simply on Wi-Fi location
detection really leaves something to be desired.

#### List of APIs involved, and the places that they occur at:

* Main map screen
    * UINavigationBarController as the wrapper for the application
    * MKMapView for the underlying map
    * CLLocationManager for getting the user's current location (heavy)
    * UIGestureRecognizer for panning on the map
    * UIButtonView for the buttons on the screen

* Directions screen
    * Segue to get to the directions screen (presented as a modal)
    * MKDirections/MKDirectionsRequest for retrieving directions from Apple Maps servers (heavy)
    * MKOverlayRenderer for drawing routes onto the MKMapView (heavy)
    * UITableView for displaying directions
    * UINavigationBar for a title and dismissing the directions
    * Custom UITableViewCell for showing directions
    * Hybrid UIView that contains a UIMapView and a UITableView
    * MKAnnotations that were placed on the map for start/end points

* Overall
    * The application works with all devices, in all orientations.
    * There is a pomeranian as the app icon. That is all.

#### Future Direction

There are a couple of things that can be done to make this app better. For example, I could add
notifications for how long I have parked my car in a place. This would allow me to run away before
a parking cop gives me a ticket. In addition, I could get Core Data working, so that I can store
all the places where I have parked my car in the past, and give each spot a rating (the code for
this data structure is actually in place). 

Completed for CS193P in Winter 2015.
