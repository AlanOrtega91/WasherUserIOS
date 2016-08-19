//
//  Payment.swift
//  Vashen
//
//  Created by Alan on 8/10/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation


public class Payment{
    
    static let HTTP_LOCATION = "Payment/"
    
    public static func getPaymentToken(token:String) throws -> String{
        let url = HttpServerConnection.buildURL(HTTP_LOCATION + "GetPaymentToken")
        let params = "token=\(token)"
        do {
            var response = try HttpServerConnection.sendHttpRequestPost(url, withParams: params)
            if response["Status"] as! String == "SESSION ERROR" {
                throw PaymentError.noSessionFound
            }
            if response["Status"] as! String != "OK" {
                throw PaymentError.errorGettingPaymentToken
            }
            
            return response["paymentToken"] as! String
        }
    }
    
    public enum PaymentError: ErrorType {
        case errorGettingPaymentToken
        case noSessionFound
    }
}