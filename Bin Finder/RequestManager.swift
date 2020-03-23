//
//  RequestManager.swift
//  Bin Finder
//
//  Created by Ciro Maione on 18/02/2020.
//  Copyright © 2020 Antonio Baldi. All rights reserved.
//

import UIKit

class RequestManager: NSObject {
    
    let FIND_BINS = "http://binfinder.altervista.org/findbins.php"

//    func makeGetCall() {
//          // Set up the URL request
//          let todoEndpoint: String = FIND_BINS
//          guard let url = URL(string: todoEndpoint) else {
//            print("Error: cannot create URL")
//            return
//          }
//          let urlRequest = URLRequest(url: url)
//
//          // set up the session
//          let config = URLSessionConfiguration.default
//          let session = URLSession(configuration: config)
//
//          // make the request
//          let task = session.dataTask(with: urlRequest) {
//            (data, response, error) in
//            // check for any errors
//            guard error == nil else {
//              print("error calling GET on /todos/1")
//              print(error!)
//              return
//            }
//            // make sure we got data
//            guard let responseData = data else {
//              print("Error: did not receive data")
//              return
//            }
//            do {
//
//                if let jsonData = data {
//                    if let jsonString = String(data: jsonData, encoding: .utf8) {
//                        print(jsonString)
//
//
//                    }
//                }
//
//            } catch  {
//              print("error trying to convert data to JSON")
//              return
//            }
//          }
//          task.resume()
//        }
    
    func getBins() -> Array<Bin> {
        // Create URL
        let url = URL(string: FIND_BINS)
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
            
            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
            }
            
        }
        task.resume()
        return Array<Bin>()
    }
}
