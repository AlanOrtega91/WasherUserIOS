//
//  AgregarPromocion.swift
//  Vashen
//
//  Created by Alan Ortega on 10/12/17.
//  Copyright © 2017 Alan. All rights reserved.
//

import Foundation
import MapKit

class AgregarPromocion: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var codigo: UITextField!
    @IBOutlet weak var mensajeError: UILabel!
    @IBOutlet weak var barraCargando: UIActivityIndicatorView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarButton: UIBarButtonItem!
    @IBOutlet weak var botonAgregar: UIButton!
    
    var latitud = ""
    var longitud = ""
    
    override func viewDidLoad() {
        if let barFont = UIFont(name: "PingFang TC", size: 17) {
            self.navigationBar.titleTextAttributes = [ NSFontAttributeName: barFont]
        }
        if let buttonFont = UIFont(name: "PingFang TC", size: 14) {
            self.navigationBarButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            latitud = String(describing: locationManager.location?.coordinate.latitude)
            longitud = String(describing: locationManager.location?.coordinate.longitude)
        }
    }
    
    
    @IBAction func agregarCodigo(_ sender: Any)
    {
        self.botonAgregar.isEnabled = false
        self.barraCargando.startAnimating()
        DispatchQueue.global().async {
            do {
                if self.codigo.text == "" {
                    return
                }
                let id = DataBase.readUser()?.id
                let codigo = self.codigo.text
                try Promocion.agregarPromocion(id: id!,codigo: codigo!,latitud: self.latitud,longitud: self.longitud)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch Promocion.PromocionError.codigoExpirado {
                self.muestraError(error: "Este codigo ya expiro")
            } catch Promocion.PromocionError.codigoNoExiste {
                self.muestraError(error: "Este codigo no existe")
            } catch Promocion.PromocionError.codigoUsado {
                self.muestraError(error: "Este codigo ya fue utilizado")
            } catch Promocion.PromocionError.ubicacion {
                self.muestraError(error: "La ubicacion actual no es valida para el codigo")
            } catch {
                self.muestraError(error: "Hubo un error al agregar el codigo")
            }
        }
    }
    
    func muestraError(error:String){
        DispatchQueue.global().async {
            self.mensajeError.text = error
            self.barraCargando.stopAnimating()
        }
    }
    
    @IBAction func regresar(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
