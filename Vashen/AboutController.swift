//
//  AboutController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class AboutController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let barFont = UIFont(name: "PingFang TC", size: 17) {
            self.navigationBar.titleTextAttributes = [ NSFontAttributeName: barFont]
        }
        if let buttonFont = UIFont(name: "PingFang TC", size: 14) {
            self.navigationBarLeftButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
    }
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func terminos(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://docs.wixstatic.com/ugd/3b7cab_b86be706129e4d23b9f51e90d1095c34.pdf")!)
    }
    
    @IBAction func privacidad(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://docs.wixstatic.com/ugd/3b7cab_639435d1b717435bbe95bc4639ccc092.pdf")!)
    }
    @IBAction func restricciones(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Menu", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "legal") as! LegalInformationController
        nextViewController.texto = "No se puede dar servicio en centros comerciales. \nSe requiere autorizar la entrada al lavador en zonas residenciales. \nSi el vehículo está demasiado sucio no se puede dar servicio."
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func ubicaciones(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Menu", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "legal") as! LegalInformationController
        nextViewController.texto = "Arboledas\n Club de golf Hacienda\n  Valle Dorado\n Satélite\n  Santa Mónica\n Cuautitlán Izcalli\n Col. Roma\n Col. Condesa"
        self.navigationController?.pushViewController(nextViewController, animated: true)

    }
    
    @IBAction func precios(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Menu", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "legal") as! LegalInformationController
        nextViewController.texto = "Moto\nExterior: $35\n\nAuto\nExterior: $55     \nExterior e Interior: $65\n\nSUV\nExterior: $65     \nExterior e Interior: $75\n\nCamioneta\nExterior: $90     \nExterior e Interior: $100\n\n"
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    @IBAction func clickedWasher(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://washer.mx/")!)
    }
}
