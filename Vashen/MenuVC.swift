//
//  MenuVC.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class MenuVC: UITableViewController {
    
    var TableArray = [String]()
    var ImageMenuArray = [UIImage]()
    
    override func viewDidLoad() {
        TableArray = ["PAGO","FACTURACION","HISTORIAL","VEHICULOS","AYUDA","SE PARTE DEL EQUIPO","CONFIGURACION","Acerca de"]
        ImageMenuArray = [UIImage(named: "pay_icon")!,UIImage(named: "bill_icon")!,UIImage(named: "hist_icon")!,UIImage(named: "car_icon")!,UIImage(named: "help_icon")!,UIImage(named: "work_icon")!,UIImage(named: "config_icon")!]
        let imageView = UIImageView(frame: self.view.frame)
        let image = UIImage(named: "background_menu")!
        imageView.image = image
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Menu", bundle:nil)
        //TODO: Add navigation controller
        switch TableArray[indexPath.row] {
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath) as! MenuCell
        cell.menuLabel.text = TableArray[indexPath.row]
        if TableArray[indexPath.row] != "Acerca de" {
            cell.menuImage.image = ImageMenuArray[indexPath.row]
        }
        
        return cell
    }
    
    
}
