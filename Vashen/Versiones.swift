//
//  Versiones.swift
//  Vashen
//
//  Created by Alan Ortega on 10/26/17.
//  Copyright © 2017 Alan. All rights reserved.
//

import Foundation

class Versiones {
    
    
    static func leerVersion() throws {
        let VERSION = "1.3.0"
        let url = "http://54.218.50.2/api/version/"
        let params = ""
        var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
        if response["version"] as! String != VERSION
        {
            if response["actualizacion"] as! String == "si" {
                throw VersionesError.actualizacionRequerida
            }
        }
    }
    
    public enum VersionesError:Error {
        case actualizacionRequerida
    }
}
