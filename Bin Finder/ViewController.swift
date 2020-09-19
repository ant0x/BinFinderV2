
//  ViewController.swift
//  Bin Finder
//
//  Created by Antonio Baldi on 11/02/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    
    @IBOutlet weak var paperBtn: UIButton!
    @IBOutlet weak var plasticBtn: UIButton!
    @IBOutlet weak var mixedBtn: UIButton!
    @IBOutlet weak var organicBtn: UIButton!
    @IBOutlet weak var glassBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 500
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bins.append(BinStruct(type: "Glass", latitude: 40.771653, longtitude: 14.794155))
        do {
            let findBins = FindBins.sharedInstance
            sleep(1)
            reload()
               }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.showsUserLocation = true
        locationManager.delegate = self
        fetchBinsOnMap(bins)
        showUserLocation(mapView)
        
        glassBtn.isSelected = true
        mixedBtn.isSelected = true
        paperBtn.isSelected = true
        organicBtn.isSelected = true
        plasticBtn.isSelected = true
        
    }
    
    
    
    
    
    @IBAction func centerMap(_ sender: Any) {
        let loc = locationManager.location
        if(loc != nil)
        {
            centerMapOnLocation(location: loc!)
        }
    }
    
    
    /*
     Aggiungere nella funzione snippet per la rimozione/ aggiunta pin sulla mappa
     */
    @IBAction func glassClick(_ sender: Any) {
        if glassBtn.isSelected {
            print(sender)
            //fai sparire qui il pin
            let image = UIImage(named: "disableGlassButton") as UIImage?
            self.glassBtn.setImage(image, for: .normal)
            self.glassBtn.isSelected = false
            restrict(filter: "Glass")
        } else {
            //fai apparire qui il pin
            let image = UIImage(named: "glassButtonSmall") as UIImage?
            self.glassBtn.setImage(image, for: .normal)
            self.glassBtn.isSelected = true
            grant(filter: "Glass")
        }
    }
    
    /*
     Aggiungere nella funzione snippet per la rimozione/ aggiunta pin sulla mappa
     */
    @IBAction func mixedClick(_ sender: Any) {
        if mixedBtn.isSelected {
            //fai sparire qui il pin
            let image = UIImage(named: "disableMixedButton") as UIImage?
            self.mixedBtn.setImage(image, for: .normal)
            self.mixedBtn.isSelected = false
            restrict(filter: "Mixed waste")
        } else {
            //fai apparire qui il pin
            let image = UIImage(named: "mixedButton") as UIImage?
            self.mixedBtn.setImage(image, for: .normal)
            self.mixedBtn.isSelected = true
            grant(filter: "Mixed waste")
        }
    }
    
    /*
     Aggiungere nella funzione snippet per la rimozione/ aggiunta pin sulla mappa
     */
    @IBAction func organicClick(_ sender: Any) {
        if organicBtn.isSelected {
            //fai sparire qui il pin
            let image = UIImage(named: "disableOrganicButton") as UIImage?
            self.organicBtn.setImage(image, for: .normal)
            self.organicBtn.isSelected = false
            restrict(filter: "Organic waste")
        } else {
            //fai apparire qui il pin
            let image = UIImage(named: "organicButton") as UIImage?
            self.organicBtn.setImage(image, for: .normal)
            self.organicBtn.isSelected = true
            grant(filter: "Organic waste")
        }
    }
    
    /*
     Aggiungere nella funzione snippet per la rimozione/ aggiunta pin sulla mappa
     */
    @IBAction func paperClick(_ sender: Any) {
        if paperBtn.isSelected {
            //fai sparire qui il pin
            let image = UIImage(named: "disablePaperButton") as UIImage?
            self.paperBtn.setImage(image, for: .normal)
            self.paperBtn.isSelected = false
            restrict(filter: "Paper")
        } else {
            //fai apparire qui il pin
            let image = UIImage(named: "paperButton") as UIImage?
            self.paperBtn.setImage(image, for: .normal)
            self.paperBtn.isSelected = true
            grant(filter: "Paper")
        }
    }
    
    
    /*
     Aggiungere nella funzione snippet per la rimozione/ aggiunta pin sulla mappa
     */
    @IBAction func plasticClick(_ sender: Any) {
        if plasticBtn.isSelected {
            //fai sparire qui il pin
            let image = UIImage(named: "disablePlasticButton") as UIImage?
            self.plasticBtn.setImage(image, for: .normal)
            self.plasticBtn.isSelected = false
            restrict(filter: "Plastic & Metals")
        } else {
            //fai apparire qui il pin
            let image = UIImage(named: "plasticButton") as UIImage?
            self.plasticBtn.setImage(image, for: .normal)
            self.plasticBtn.isSelected = true
            grant(filter: "Plastic & Metals")
        }
    }
    
    
    @IBAction func resetClick(_ sender: Any) {
        //plastic
        var image = UIImage(named: "plasticButton") as UIImage?
        self.plasticBtn.setImage(image, for: .normal)
        self.plasticBtn.isSelected = true
        grant(filter: "Plastic & Metals")
        //paper
        image = UIImage(named: "paperButton") as UIImage?
        self.paperBtn.setImage(image, for: .normal)
        self.paperBtn.isSelected = true
        grant(filter: "Paper")
        //glass
        image = UIImage(named: "glassButtonSmall") as UIImage?
        self.glassBtn.setImage(image, for: .normal)
        self.glassBtn.isSelected = true
        grant(filter: "Glass")
        //mixed
        image = UIImage(named: "mixedButton") as UIImage?
        self.mixedBtn.setImage(image, for: .normal)
        self.mixedBtn.isSelected = true
        grant(filter: "Mixed waste")
        //organic
        image = UIImage(named: "organicButton") as UIImage?
        self.organicBtn.setImage(image, for: .normal)
        self.organicBtn.isSelected = true
        grant(filter: "Organic waste")
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,
                                                       latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    //questa funzione deve essere chiamata quando lo user vuole indicazioni per arrivare al cestino
    func onIndicationRequest(sourceLocationLatitude: CLLocationDegrees, sourceLocationLongitude: CLLocationDegrees, destinationLocationLatitude: CLLocationDegrees, destinationLocationLongitude: CLLocationDegrees) {
        
        let sourceLocation = CLLocationCoordinate2D(latitude: sourceLocationLatitude, longitude: sourceLocationLongitude)
        
        let destinationLocation = CLLocationCoordinate2D(latitude: destinationLocationLatitude, longitude: destinationLocationLongitude)
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions == \(error.localizedDescription)")
                }
                return
            }
            let route = directionResonse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
        self.mapView.delegate = self
        
    }
    
    
    
    @objc func showUserLocation(_ sender: AnyObject) {
        //        print("\nStart of showUserLocation()")
        //        print("\nUser's location: lat=\(mapView.userLocation.coordinate.latitude), lon=\(mapView.userLocation.coordinate.longitude), title=\(mapView.userLocation.title!)")
        
        
        switch CLLocationManager.authorizationStatus() {
        case CLAuthorizationStatus.notDetermined, .restricted, .denied:
            locationManager.requestWhenInUseAuthorization()
        case CLAuthorizationStatus.authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        default:
            fatalError()
        }
        
        //        print("\nEnd of showUserLocation()")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //        print("\nStart of locationManager(didChangeAuthorization)")
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == CLAuthorizationStatus.authorizedWhenInUse
            || authStatus == CLAuthorizationStatus.authorizedAlways {
            requestLocation()
            zoomInLocation(manager.location!)
        }
        
        print("\nEnd of locationManager(didChangeAuthorization)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        print("\nStart of locationManager(didUpdateLocations)")
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //        print("locations = \(locValue.latitude) \(locValue.longitude)")
        //zoomInLocation(locations.last!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let err = error as? CLError, err.code == .denied {
            manager.stopUpdatingLocation()
            return
        }
        //        print("\nlocationManager(): \(error.localizedDescription)")
    }
    
    private func requestLocation() {
        //        print("\requestLocation() called")
        
        // check if the location service is availalbe on that device
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        
        locationManager.requestLocation()
    }
    
    private func zoomInLocation(_ location: CLLocation) {
        //        print("\nzoomInUserLocation(): mapView[latitude]=\(location.coordinate.latitude), locationManager[latitude]=\(String(describing: location.coordinate.latitude))")
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, span: coordinateSpan)
        mapView.centerCoordinate = location.coordinate
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    @objc func route(sender: cButton) {
        let location = sender.coordinate
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location, addressDictionary:nil))
        mapItem.name = sender.annotation.title!
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
    }
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView) {
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if (annotation is MKUserLocation) {
            return nil
        }
        let reuseId = ""
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        
        
        let mapsButton = cButton(annotation: annotation ,frame: CGRect(origin: CGPoint.zero,
                                                                       size: CGSize(width: 40, height: 40)))
        mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
        mapsButton.addTarget(self, action:#selector(route), for: .touchUpInside)
        
        
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            
            switch annotation.title {
            case "Paper":
                anView?.image = UIImage(named:"paper")
                anView?.canShowCallout = true
            case "Glass":
                anView?.image = UIImage(named:"glass")
                anView?.canShowCallout = true
            case "Plastic & Metals":
                anView?.image = UIImage(named:"plastic")
                anView?.canShowCallout = true
            case "Mixed waste":
                anView?.image = UIImage(named:"mixed")
                anView?.canShowCallout = true
            case "Organic waste":
                anView?.image = UIImage(named:"organic")
                anView?.canShowCallout = true
            default:
                print("default")
            }
            anView?.rightCalloutAccessoryView = mapsButton
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView?.annotation = annotation
        }
        return anView
    }
    
    
    
    
    func fetchBinsOnMap(_ bins: [BinStruct]) {
        for annotation in mapView.annotations
        {
            mapView.removeAnnotation(annotation)
        }
        
        for bin in bins {
            if(bin.visible)
            {
                let annotations = MKPointAnnotation()
                annotations.title = bin.type
                annotations.coordinate = CLLocationCoordinate2D(latitude: bin.latitude, longitude: bin.longtitude)
                mapView.delegate = self
                mapView.addAnnotation(annotations)
            }
        }
    }
    
    
    @IBAction func addBinButton(_ sender: Any) {
        //print(locationManager.location!.coordinate)
    }
    
    public func reload()
    {
        fetchBinsOnMap(bins)
    }
    
    func applyRoundCorner(_ object:AnyObject) {
        object.layer?.cornerRadius = object.frame.size.width / 2
        object.layer?.masksToBounds = true
    }
    
    func restrict(filter:String)
    {
        if (glassBtn.isSelected && paperBtn.isSelected && plasticBtn.isSelected && mixedBtn.isSelected && organicBtn.isSelected)
        {
            for index in 0..<bins.count
            {
                if(bins[index].type != filter)
                {
                    /*
                     switch bins[index].type {
                     case "Paper":
                     paperClick(paperBtn as Any)
                     case "Glass":
                     glassClick(glassBtn as Any)
                     case "Plastic & Metals":
                     plasticClick(plasticBtn as Any)
                     case "Mixed waste":
                     mixedClick(mixedBtn as Any)
                     case "Organic waste":
                     organicClick(organicBtn as Any)
                     default:
                     print("default")
                     }
                     */
                    bins[index].visible = false
                }
            }
        }
        else
        {
            for index in 0..<bins.count
            {
                if(bins[index].type == filter)
                {
                    bins[index].visible = false
                }
            }
        }
        fetchBinsOnMap(bins)
    }
    
    func grant(filter:String)
    {
        for index in 0..<bins.count
        {
            if(bins[index].type == filter)
            {
                bins[index].visible = true
            }
        }
        fetchBinsOnMap(bins)
    }
    
    
    
    
}
