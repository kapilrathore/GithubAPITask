//
//  NetworkOperation.swift
//  GithubAPITask
//
//  Created by Kapil Rathore on 05/04/17.
//  Copyright © 2017 Kapil Rathore. All rights reserved.
//

import Foundation

class NetworkOperation {
    
    lazy var config: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = URLSession(configuration: self.config)
    let queryURL: URL
    
    typealias JSONDictionaryCompletion = (([[String: AnyObject]]?) -> Void)
    
    init(url: URL) {
        self.queryURL = url
    }
    
    func downloadJSONFromURL(completion: @escaping JSONDictionaryCompletion) {
        
        let request = NSMutableURLRequest(url: queryURL)
        let dataTask = session.dataTask(with: request as URLRequest) {
            ( data, response, error) in
            
            // 1. Check HTTP response for successful GET request
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    // 2. Create JSON object with data
                    do {
                        let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: AnyObject]]
                        completion(jsonDictionary)
                    } catch {
                        completion(nil)
                        print("Fetch failed: \((error as NSError).localizedDescription)")
                    }
                default:
                    print("GET request not successful. HTTP status code: \(httpResponse.statusCode)")
                }
            } else {
                print("Error: Not a valid HTTP response")
            }
        }
        
        dataTask.resume()
    }
}
