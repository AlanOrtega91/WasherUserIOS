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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Menu", bundle:nil)
        //TODO: Add navigation controller
        if indexPath.row > 0 {
            switch TableArray[indexPath.row - 1] {
            case TableArray[0]:
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("payment") as! PaymentController
                self.presentViewController(nextViewController, animated:true, completion:nil)
                break
            case TableArray[1]:
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("billing") as! BillingController
                self.presentViewController(nextViewController, animated:true, completion:nil)
                break
            case TableArray[2]:
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("history") as! HistoryController
                self.presentViewController(nextViewController, animated:true, completion:nil)
                break
            case TableArray[3]:
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("cars") as! CarsController
                self.presentViewController(nextViewController, animated:true, completion:nil)
                break
            case TableArray[4]:
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("help") as! HelpController
                self.presentViewController(nextViewController, animated:true, completion:nil)
                break
            case TableArray[5]:
                let url = NSURL(string: "https://google.com")!
                UIApplication.sharedApplication().openURL(url)
                break
            case TableArray[6]:
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("configuration") as! ConfigurationController
                self.presentViewController(nextViewController, animated:true, completion:nil)
                break
            case TableArray[7]:
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("about") as! AboutController
                self.presentViewController(nextViewController, animated:true, completion:nil)
                break
            default:
                return
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let user = DataBase.readUser()
            let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as! HeaderCell
            if user.encodedImage != nil {
                let dataDecoded = NSData(base64EncodedString: user.encodedImage, options: .IgnoreUnknownCharacters)
                //cell.userImage.image = UIImage(data: dataDecoded!)!
            }
            cell.userName.text = user.name + " " + user.lastName
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath) as! MenuCell
            cell.menuLabel.text = TableArray[indexPath.row - 1]
            if TableArray[indexPath.row - 1] != "Acerca de" {
                cell.menuImage.image = ImageMenuArray[indexPath.row - 1]
            }
            return cell
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 120
        } else {
            return 50
        }
    }
    
    
}
