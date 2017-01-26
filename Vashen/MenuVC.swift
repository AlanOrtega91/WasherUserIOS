//
//  MenuVC.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class MenuVC: UITableViewController {
    
    var TableArray = ["PAGO","FACTURACION","HISTORIAL","VEHICULOS","AYUDA","SE PARTE DEL EQUIPO","CONFIGURACION","Acerca de"]
    var ImageMenuArray = [UIImage(named: "pay_icon")!,UIImage(named: "billing_icon")!,UIImage(named: "history_icon")!,UIImage(named: "vehicle_icon")!,UIImage(named: "help_icon")!,UIImage(named: "work_icon")!,UIImage(named: "config_icon")!]
    
    override func viewDidLoad() {
        let imageView = UIImageView(frame: self.tableView.frame)
        let image = UIImage(named: "background_menu")!
        imageView.image = image
        self.tableView.backgroundView = imageView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell
        if let user = DataBase.readUser() {
            if user.encodedImage != "" {
                if let userImage = User.readImageDataFromFile(name: user.encodedImage) {
                    cell.userImage.image = userImage
                }
            } else {
                cell.userImage.image = UIImage(named: "default_image")
            }
            cell.userName.text = user.name + " " + user.lastName
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Menu", bundle:nil)
        var nextViewController:UIViewController? = nil
        switch TableArray[indexPath.row] {
        case TableArray[0]:
            nextViewController = storyBoard.instantiateViewController(withIdentifier: "payment") as! PaymentController
            break
        case TableArray[1]:
            nextViewController = storyBoard.instantiateViewController(withIdentifier: "billing") as! BillingController
            break
        case TableArray[2]:
            nextViewController = storyBoard.instantiateViewController(withIdentifier: "history") as! HistoryController
            break
        case TableArray[3]:
            nextViewController = storyBoard.instantiateViewController(withIdentifier: "cars") as! CarsController
            break
        case TableArray[4]:
            nextViewController = storyBoard.instantiateViewController(withIdentifier: "help") as! HelpController
            break
        case TableArray[5]:
            if let url = URL(string: "http://www.washer.mx") {
                UIApplication.shared.openURL(url)
            }
            break
        case TableArray[6]:
            nextViewController = storyBoard.instantiateViewController(withIdentifier: "configuration") as! ConfigurationController
            break
        case TableArray[7]:
            nextViewController = storyBoard.instantiateViewController(withIdentifier: "about") as! AboutController
            break
        default:
            return
        }
        if (nextViewController != nil) {
            self.navigationController?.pushViewController(nextViewController!, animated: true)
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath as IndexPath) as! MenuCell
        cell.menuLabel.text = TableArray[indexPath.row]
        cell.menuDivider.isHidden = false
        if TableArray[indexPath.row] != "Acerca de" {
            cell.menuDivider.isHidden = true
            cell.menuImage.image = ImageMenuArray[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView : UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
}
