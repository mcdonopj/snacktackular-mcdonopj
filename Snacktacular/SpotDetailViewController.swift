//
//  SpotDetailViewController.swift
//  Snacktacular
//
//  Created by John Gallaugher on 3/23/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit
import Contacts

class SpotDetailViewController: UIViewController {
    var spot: Spot!
    let regionDistance: CLLocationDistance = 750 //750m = half mile about
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
      //  mapView.delegate = self
        super.viewDidLoad()
        if spot == nil {
            spot = Spot()
            getLocation()
        }
//        nameField.text = spot.name
//        addressField.text = spot.address
        let region = MKCoordinateRegion(center: spot.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
   
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateUserInterface() {
        nameField.text = spot.name
        addressField.text = spot.address
        updateMap()
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(spot)
        mapView.setCenter(spot.coordinate, animated: true)
    }

    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
            if isPresentingInAddMode {
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        
    }
    
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func reviewButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        spot.name = nameField.text!
        spot.address = nameField.text!
        spot.saveData { success in
            if success {
                self.leaveViewController() //do i need the self???????
                print("😁😁😁😁😁😁😁😁😁😁😁😁😁😁do i need the self?????")
            } else {
                print("😁😁😁😁😁😁😁😁😁😁😁😁😁😁😁😁error: coudlnt leave this view controller because data wasnt saved")
            }
        }
    }
    
    
    
    @IBAction func lookUpPlacePressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
}

extension SpotDetailViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    spot.name = place.name ?? "UNKNOWN PLACE"
    spot.address = place.formattedAddress ?? "UNKNOWN ADDRESS"
    spot.coordinate = place.coordinate
    dismiss(animated: true, completion: nil)
    updateUserInterface()
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }

}

extension SpotDetailViewController: CLLocationManagerDelegate {
    func getLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            print("I'm sorry - can't show location. User has not authorized it.")
        case .restricted:
            print("Access deined. Likely parental controls restrict location services in this app.")
            showAlert(title: "Access Denied.", message: "Likely parental controls restrict location services in this app.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard spot.name == "" else {
            return
        }
    let geoCoder = CLGeocoder()
        var name = ""
        var address = ""
        currentLocation = locations.last
        spot.coordinate = currentLocation.coordinate
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {placemarks, error in
            if placemarks != nil {
            let placemark = placemarks?.last
            name = placemark?.name ?? "name unknown"
            //need to import conetacts to use this code
            
        if let postalAddress = placemark?.postalAddress {
            address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
        }
    } else {
    print("error retreiving place. error code: \(error!.localizedDescription)")
    }
    self.spot.name = name
    self.spot.address = address
    self.updateUserInterface()
    })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to get user location")
}

}
