//
//  HttpServerConnection.swift
//  Vashen
//
//  Created by Alan on 8/3/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

public class HttpServerConnection
{
    private static var dev = "192.168.0.2"
    private static var prod = "imanio.zone"
    
    public static func buildURL(location: String) -> String {
        let path = ("http://" + prod + "/Vashen/API/" + location + "/")
        return path
    }
    
    public static func sendHttpRequestPost(urlPath: String, withParams params: String) throws -> Dictionary<String,AnyObject>{
        do {
            var response : URLResponse?
            let request = NSMutableURLRequest.init(url: NSURL.init(string: urlPath)! as URL)
            request.httpMethod = "POST"
            request.timeoutInterval = 5
            request.httpBody = params.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
            let data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
            print(String(data: data, encoding: String.Encoding.utf8))
            let dataString = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
            return dataString as! Dictionary<String, AnyObject>
        } catch (let e) {
            print(e)
            throw HTTPError.connectionException
        }
    }
    enum  HTTPError: Error {
        case connectionException
    }
}
