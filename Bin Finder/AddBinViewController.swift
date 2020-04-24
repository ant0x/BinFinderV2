//
//  AddBinViewController.swift
//  Bin Finder
//
//  Created by Antonio Baldi on 24/04/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class AddBinViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, MKMapViewDelegate
{
    
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var pickerView: UIPickerView!
    let type = ["Plastic & Metals","Paper","Glass","Mixed waste","Organic waste"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return type.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return type[row]
    }
    
    
    @IBAction func addBin(_ sender: Any) {
        locationManager.delegate = self as? CLLocationManagerDelegate
        let selected = type[pickerView.selectedRow(inComponent: 0)]
        
        let newBin = BinStruct(type: selected, latitude: (locationManager.location?.coordinate.latitude)!
            , longtitude: (locationManager.location?.coordinate.longitude)!)
        bins.append(newBin)
        print("Added")
        print(selected)
        FindBins.sharedInstance.addBin(bin: newBin)
        let main = self.presentingViewController as! ViewController
        self.dismiss(animated: true) {
            main.reload()
        }
    }
    
    
    @IBAction func touchCancelOperation(_ sender: Any) {
        let main = self.presentingViewController as! ViewController
        self.dismiss(animated: true) {
            main.reload()
        }
    }
    
}
