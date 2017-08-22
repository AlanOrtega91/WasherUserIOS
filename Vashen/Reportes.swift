//
//  Reportes.swift
//  Vashen
//
//  Created by Alan on 12/06/17.
//  Copyright © 2017 Alan. All rights reserved.
//

import Foundation

public class Reportes {
static var HTTP_LOCATION = "Reporte"

public static func sendReport(descripcion: String, latitud:Double, longitud:Double){
    let url = HttpServerConnection.buildURL(location: HTTP_LOCATION)
    let params = "descripcion=\(descripcion)&latitud=\(latitud)&longitud=\(longitud)"
    do{
        _ = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
    } catch {
        print("Error en reporte")
    }
}
}
