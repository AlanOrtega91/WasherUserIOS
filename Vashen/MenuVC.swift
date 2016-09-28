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
    var ImageMenuArray = [UIImage(named: "pay_icon")!,UIImage(named: "bill_icon")!,UIImage(named: "hist_icon")!,UIImage(named: "car_icon")!,UIImage(named: "help_icon")!,UIImage(named: "work_icon")!,UIImage(named: "config_icon")!]
    
    override func viewDidLoad() {
        let imageView = UIImageView(frame: self.tableView.frame)
        let image = UIImage(named: "background_menu")!
        imageView.image = image
        self.tableView.backgroundView = imageView
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let user = DataBase.readUser()
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell
        if user.encodedImage != nil {
            let dataDecoded = NSData(base64Encoded: user.encodedImage, options: .ignoreUnknownCharacters)
            cell.userImage.image = UIImage(data: dataDecoded! as Data)!
        }
        cell.userName.text = user.name + " " + user.lastName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Menu", bundle:nil)
        var nextViewController = storyBoard.instantiateViewController(withIdentifier: "payment")
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
            let url = NSURL(string: "https://google.com")!
            UIApplication.shared.openURL(url as URL)
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
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath as IndexPath) as! MenuCell
        cell.menuLabel.text = TableArray[indexPath.row]
        if TableArray[indexPath.row] != "Acerca de" {
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
