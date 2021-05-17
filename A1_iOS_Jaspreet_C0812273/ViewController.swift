//
//  ViewController.swift
//  MapKitDemo
//
//  Created by Jaspreet Kaur on 15/05/21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var stadiums = [Stadium]()
    var objPolyline  = [CLLocationCoordinate2D]()
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.showsUserLocation = true
        
        self.mapView.isZoomEnabled = true;
        self.mapView.isScrollEnabled = true;
        self.mapView.isUserInteractionEnabled = true;
        
        let gestureLong = UITapGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
        self.mapView.addGestureRecognizer(gestureLong)
        
        
    }
    
    @IBAction func routeBtnAction(_ sender: Any) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        if objPolyline.count > 0 {
            showRouteOnMap(pickupCoordinate: objPolyline[0], destinationCoordinate: objPolyline[1])
            showRouteOnMap(pickupCoordinate: objPolyline[1], destinationCoordinate: objPolyline[2])
            showRouteOnMap(pickupCoordinate: objPolyline[2], destinationCoordinate: objPolyline[0])
        }
        
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .denied: // Show alert telling users how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        case .restricted: // Show an alert letting them know what’s up
            break
        case .authorizedAlways:
            break
        }
    }
    
    func fetchStadiumsOnMap(_ stadiums: [Stadium]) {
        for stadium in stadiums {
            let annotations = MKPointAnnotation()
            annotations.title = stadium.name
            annotations.coordinate = CLLocationCoordinate2D(latitude:
                                                                stadium.lattitude, longitude: stadium.longtitude)
            mapView.addAnnotation(annotations)
        }
    }
    
    @objc func handleLongPress(gestureReconizer: UITapGestureRecognizer) {
        switch stadiums.count {
        case 0:
            let touchLocation = gestureReconizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation,toCoordinateFrom: mapView)
            print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            let objStadium = Stadium(name: "A", lattitude: locationCoordinate.latitude, longtitude: locationCoordinate.longitude)
            self.stadiums.append(objStadium)
            objPolyline.append(locationCoordinate)
        case 1:
            let touchLocation = gestureReconizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation,toCoordinateFrom: mapView)
            print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            let objStadium = Stadium(name: "B", lattitude: locationCoordinate.latitude, longtitude: locationCoordinate.longitude)
            self.stadiums.append(objStadium)
            objPolyline.append(locationCoordinate)
        case 2:
            let touchLocation = gestureReconizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation,toCoordinateFrom: mapView)
            print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            let objStadium = Stadium(name: "C", lattitude: locationCoordinate.latitude, longtitude: locationCoordinate.longitude)
            self.stadiums.append(objStadium)
            objPolyline.append(locationCoordinate)
            makePolyline()
            makePolygon()
        case 3:
            objPolyline.removeAll()
            stadiums.removeAll()
            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(mapView.annotations)
        default:
            print("Default")
        }
        fetchStadiumsOnMap(stadiums)
        
        return
        
    }
    
    func makePolyline(){
        let polyline = MKPolyline(coordinates: objPolyline, count: objPolyline.count)
        mapView.addOverlay(polyline)
    }
    
    func makePolygon(){
        let polygon = MKPolygon(coordinates: objPolyline, count: objPolyline.count)
        mapView?.addOverlay(polygon)
    }
    
    func calculateDistance(sourceLat: CLLocationDegrees, sourceLong: CLLocationDegrees, destinationLat: CLLocationDegrees, destinationLong : CLLocationDegrees) -> CGFloat {
        
        if stadiums.count > 1 {
            let coordinate1 = CLLocation(latitude: sourceLat, longitude: sourceLong)
            let coordinate2 = CLLocation(latitude: destinationLat, longitude: destinationLong)
            let distanceInMeters = coordinate1.distance(from: coordinate2)
            return CGFloat(distanceInMeters)
        }
        return CGFloat()
    }
}

extension ViewController : MKMapViewDelegate,  CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }

        let mapCamera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude), fromDistance: 10000, pitch: 50, heading: 0)
        mapView.setCamera(mapCamera, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Did Selecte Tap",view.annotation?.title)
        let subtitleView = UILabel()
        
        if stadiums.count == 3 {
            if view.annotation?.title == "A" {
                let distance = round((calculateDistance(sourceLat: stadiums[0].lattitude, sourceLong: stadiums[0].longtitude, destinationLat: stadiums[1].lattitude, destinationLong: stadiums[1].longtitude)/1000))
                subtitleView.text = "Distance Form A to B \(distance)"
            } else if view.annotation?.title == "B" {
                let distance = round((calculateDistance(sourceLat: stadiums[1].lattitude, sourceLong: stadiums[1].longtitude, destinationLat: stadiums[2].lattitude, destinationLong: stadiums[2].longtitude)/1000))
                subtitleView.text = "Distance Form B to C \(distance)"
            } else if view.annotation?.title == "C" {
                let distance = round((calculateDistance(sourceLat: stadiums[2].lattitude, sourceLong: stadiums[2].longtitude, destinationLat: stadiums[0].lattitude, destinationLong: stadiums[0].longtitude)/1000))
                subtitleView.text = "Distance Form C to A \(distance)"
            }
        }
        //Adding Subtitle text
        
        view.detailCalloutAccessoryView = subtitleView
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
            
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
            renderer.lineWidth = 2
            return renderer
            
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 2
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        
        
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.init(type: UIButton.ButtonType.detailDisclosure)
//        let subtitleView = UILabel()
//
//        if stadiums.count == 3 {
//            if annotation.title == "A" {
//                let distance = round((calculateDistance(sourceLat: stadiums[0].lattitude, sourceLong: stadiums[0].longtitude, destinationLat: stadiums[1].lattitude, destinationLong: stadiums[1].longtitude)/1000))
//                subtitleView.text = "Distance Form A to B \(distance)"
//            } else if annotation.title == "B" {
//                let distance = round((calculateDistance(sourceLat: stadiums[1].lattitude, sourceLong: stadiums[1].longtitude, destinationLat: stadiums[2].lattitude, destinationLong: stadiums[2].longtitude)/1000))
//                subtitleView.text = "Distance Form B to C \(distance)"
//            } else if annotation.title == "C" {
//                let distance = round((calculateDistance(sourceLat: stadiums[2].lattitude, sourceLong: stadiums[2].longtitude, destinationLat: stadiums[0].lattitude, destinationLong: stadiums[0].longtitude)/1000))
//                subtitleView.text = "Distance Form C to A \(distance)"
//            }
//        }
//        //Adding Subtitle text
//
//
//
//        annotationView.detailCalloutAccessoryView = subtitleView
        
        return annotationView
    }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        print("view.tag ",view.tag)
//    }
//
}

struct Stadium {
    var name: String
    var lattitude: CLLocationDegrees
    var longtitude: CLLocationDegrees
}

struct Polyline {
    var polyLines : CLLocationCoordinate2D
}
