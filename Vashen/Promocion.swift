//
//  Promocion.swift
//  Vashen
//
//  Created by Alan Ortega on 10/12/17.
//  Copyright © 2017 Alan. All rights reserved.
//

import Foundation

class Promocion {
    static var HTTP_LOCATION = "promocion/"
    
    var codigo:String = ""
    var nombre:String = ""
    var descripcion:String = ""
    
    static func leerPromocion(id:String) throws -> [Promocion] {
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "leerPromociones")
        let params = "id=\(id)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String == "error"
            {
                throw PromocionError.errorLeyendoPromociones
            }
            
            let parameters = response["promociones"] as! [NSDictionary]
            var promociones:[Promocion] = []
            for json:NSDictionary in parameters {
                let promocion = Promocion()
                promocion.codigo = json["codigo"] as! String
                promocion.nombre = json["nombre"] as! String
                promocion.descripcion = json["descripcion"] as! String
                promociones.append(promocion)
            }
            return promociones
        } catch HttpServerConnection.HttpError.connectionException{
            throw PromocionError.errorLeyendoPromociones
        }
    }
    
    
    static func agregarPromocion(id:String!, codigo:String!, latitud:String!, longitud:String!) throws {
        let url = HttpServerConnection.buildURL(location: HTTP_LOCATION + "agregarPromocion")
        let params = "id=\(id)&codigo=\(codigo)&latitud=\(latitud)&longitud=\(longitud)"
        do{
            var response = try HttpServerConnection.sendHttpRequestPost(urlPath: url, withParams: params)
            if response["estado"] as! String == "error"
            {
                switch response["clave"] as! String {
                case "codigoNoExiste":
                    throw PromocionError.codigoNoExiste
                case "codigoUsado":
                    throw PromocionError.codigoUsado
                case "codigoExpirado":
                    throw PromocionError.codigoExpirado
                case "ubicacion":
                    throw PromocionError.ubicacion
                default:
                    throw PromocionError.errorLeyendoPromociones
                }
            }

        } catch HttpServerConnection.HttpError.connectionException{
            throw PromocionError.errorLeyendoPromociones
        }
    }
    
    enum PromocionError:Error {
        case errorLeyendoPromociones
        case errorAgregandoCodigo
        case codigoNoExiste
        case codigoUsado
        case codigoExpirado
        case ubicacion
    }
}
