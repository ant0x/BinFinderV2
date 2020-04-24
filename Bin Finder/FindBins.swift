//
//  BinFinder.swift
//  Bin Finder
//
//  Created by Antonio Baldi on 18/02/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import UIKit
import CoreLocation

class FindBins: NSObject {
    
    static let sharedInstance = FindBins()
    //let main = ViewController.main
    
    struct BinRequest: Codable {
        var id: String
        var latitude: String
        var longitude: String
        var type: String
    }
        
    
    private override init() {

        super.init()
        
        
        performRequest()

    }
    
    func performRequest() {
        
        // Create URL
        let url = URL(string: "http://binfinder.altervista.org/findbins.php")
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        // Send HTTP Request
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            var res: Array<BinRequest>?
            do {
                res = try JSONDecoder().decode(Array<BinRequest>.self, from: data!)
            } catch {
                print("Error took place\(error).")
            }

            
            for bin in res! {
                bins.append(BinStruct(type: bin.type, latitude: Double(bin.latitude)!, longtitude: Double(bin.longitude)!))
            }
            
        }
        task.resume()
    }
    
    
    func addBin(bin: BinStruct) {
        // Create URL
        let ty = bin.type.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let url = URL(string: "http://binfinder.altervista.org/addbin.php?latitude=\(bin.latitude)&longitude=\(bin.longtitude)&type=\(ty)")
        print(url!)
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        // Send HTTP Request
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
}

