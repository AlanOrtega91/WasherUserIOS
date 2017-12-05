//
//  PromocionesController.swift
//  Vashen
//
//  Created by Alan Ortega on 10/12/17.
//  Copyright © 2017 Alan. All rights reserved.
//

import Foundation

class PromocionesController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var codigo: UILabel!
    @IBOutlet weak var listaPromociones: UITableView!
    @IBOutlet weak var barraCargando: UIActivityIndicatorView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarButton: UIBarButtonItem!
    var promociones:[Promocion] = []
    
    override func viewDidLoad() {
        if let barFont = UIFont(name: "PingFang TC", size: 17) {
            self.navigationBar.titleTextAttributes = [ NSFontAttributeName: barFont]
        }
        if let buttonFont = UIFont(name: "PingFang TC", size: 14) {
            self.navigationBarButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
        codigo.text = DataBase.readUser()?.codigo
        listaPromociones.delegate = self
        listaPromociones.dataSource = self
        DispatchQueue.global().async {
            if let id = DataBase.readUser()?.id {
                do {
                    self.promociones = try Promocion.leerPromocion(id: id)
                    DispatchQueue.main.async {
                        self.listaPromociones.reloadData()
                        self.barraCargando.stopAnimating()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.createAlertInfo(message: "Error leyendo tus promociones")
                        self.barraCargando.stopAnimating()
                    }
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return promociones.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "promocionCell", for: indexPath as IndexPath) as! PromocionCell
        let promocion = promociones[indexPath.row]
        cell.codigo.text = promocion.codigo
        cell.nombre.text = promocion.nombre
        return cell
    }
    
    @IBAction func copiarCodigo(_ sender: Any)
    {
        UIPasteboard.general.string = self.codigo.text
    }
    
    @IBAction func regresarAMenu(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func createAlertInfo(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
