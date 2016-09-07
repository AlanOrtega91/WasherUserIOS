//
//  MapController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit
import GoogleMaps

class MapController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var menuOpenButton: UIBarButtonItem!
    
    @IBOutlet weak var mapView: UIView!
    var map: GMSMapView!
    
    
    @IBOutlet weak var upLayout: UIView!
    @IBOutlet weak var upLayoutHeight: NSLayoutConstraint!
    let upLayoutSize = CGFloat(50)
    @IBOutlet weak var lowLayout: UIView!
    @IBOutlet weak var lowLayoutHeight: NSLayoutConstraint!
    let lowLayoutSize = CGFloat(100)
    @IBOutlet weak var startLayout: UIView!
    @IBOutlet weak var startLayoutHeight: NSLayoutConstraint!
    let startLayoutSize = CGFloat(90)

    @IBOutlet weak var serviceInfo: UILabel!
    @IBOutlet weak var cleanerInfo: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var cleanerImageInfo: UIImageView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var rightDescription: UILabel!
    @IBOutlet weak var leftDescription: UILabel!

    @IBOutlet weak var bikeImage: UIButton!
    @IBOutlet weak var smallCarImage: UIButton!
    @IBOutlet weak var bigCarImage: UIButton!
    @IBOutlet weak var smallVanImage: UIButton!
    @IBOutlet weak var bigVanImage: UIButton!
    @IBOutlet weak var locationText: UITextField!

    
    
    
    var showCancelAler: Bool = false
    
    var locManager = CLLocationManager()
    var cleaners: Array<Cleaner> = Array<Cleaner>()
    
    var idClient:String!
    var token:String!
    var user: User!
    var creditCard: UserCard!
    var activeService: Service!
    var viewState = Int()
    final var STANDBY = 0
    final var VEHICLE_SELECTED = 1
    final var SERVICE_SELECTED = 2
    final var SERVICE_TYPE_SELECTED = 3
    final var SERVICE_START = 4
    var serviceRequestFlag: Bool = false
    var requestLocation: CLLocation!
    var serviceType:String!
    var vehicleType:String!
    var service:String!
    var cancelCode:Int = 0
    var cancelSent:Bool = false
    var activeServiceCycleThread:NSThread!
    var cancelAlarmClock:NSTimer!
    var clock:NSTimer!
    var nearbyCleanersTimer:dispatch_source_t!
    var reloadMapTimer:dispatch_source_t!
    
    let centralMarker = GMSMarker()
    let cleanerMarker = GMSMarker()
    var markers: Array<GMSMarker> = Array<GMSMarker>()
    var cleaner:Cleaner!
    var showCancelAlert:Bool = false
    var userLocation: CLLocation!
    var inScope:Bool = false
    
    var clickedAlertOK = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocation()
        initView()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC/3)), dispatch_get_main_queue(), {
            self.initMap()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        onResume()
    }
    
    func onResume(){
        cleaners.removeAll()
        initValues()
        configureServices()
        initTimers()
        if showCancelAlert {
            buildAlertForCancel()
            showCancelAlert = false
        }
        inScope = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        inScope = false
        cancelTimers()
    }
    
    func cancelTimers(){
        dispatch_source_cancel(nearbyCleanersTimer)
        dispatch_source_cancel(reloadMapTimer)
    }
    
    func initValues(){
        idClient = AppData.readUserId()
        token = AppData.readToken()
        user = DataBase.readUser()
        creditCard = DataBase.readCard()
        activeService = DataBase.getActiveService()
        if activeService == nil {
            viewState = STANDBY
            configureState()
        } else if activeService.status == "Finished" {
            viewState == SERVICE_START
            configureState()
            
            let storyBoard = UIStoryboard(name: "Map", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("summary") as! SummaryController
            self.presentViewController(nextViewController, animated: true, completion: nil)
        } else {
            viewState = SERVICE_START
            configureState()
            startActiveServiceCycle()
        }
    }
    
    func configureServices(){
        bikeImage.alpha = 0.5
        smallCarImage.alpha = 0.5
        bigCarImage.alpha = 0.5
        smallVanImage.alpha = 0.5
        bigVanImage.alpha = 0.5
        bikeImage.userInteractionEnabled = false
        smallCarImage.userInteractionEnabled = false
        bigCarImage.userInteractionEnabled = false
        smallVanImage.userInteractionEnabled = false
        bigVanImage.userInteractionEnabled = false
        
        var type = 6
        let selectedCar = DataBase.getFavoriteCar()
        if selectedCar != nil {
            type = Int(selectedCar!.type)!
        }
        
        switch type {
        case Service.BIKE:
            bikeImage.alpha = 1
            bikeImage.userInteractionEnabled = true
        case Service.SMALL_CAR:
            smallCarImage.alpha = 1
            smallCarImage.userInteractionEnabled = true
        case Service.BIG_CAR:
            bigCarImage.alpha = 1
            bigCarImage.userInteractionEnabled = true
        case Service.SMALL_VAN:
            smallVanImage.alpha = 1
            smallVanImage.userInteractionEnabled = true
        case Service.BIG_VAN:
            bigVanImage.alpha = 1
            bigVanImage.userInteractionEnabled = true
        default:
            break
        }
    }
    
    func initTimers(){
        let  nearbyCleanersQueue = dispatch_queue_create("com.alan.nearbyCleaners", DISPATCH_QUEUE_CONCURRENT);
        nearbyCleanersTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, nearbyCleanersQueue);
        dispatch_source_set_timer(nearbyCleanersTimer, dispatch_time(DISPATCH_TIME_NOW, 0), NSEC_PER_SEC, 2*NSEC_PER_SEC);
        
        dispatch_source_set_event_handler(nearbyCleanersTimer, {
            dispatch_async(dispatch_get_main_queue(), {
                print("nearbyCleaners")
                let tempLocation = self.requestLocation
                if self.activeService == nil && self.requestLocation != nil {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        self.nearbyCleaners(tempLocation)
                    });
                }
            })
        });
        dispatch_resume(nearbyCleanersTimer);
        
        let  reloadMapQueue = dispatch_queue_create("com.alan.reloadMap", DISPATCH_QUEUE_CONCURRENT);
        reloadMapTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, reloadMapQueue);
        dispatch_source_set_timer(reloadMapTimer, dispatch_time(DISPATCH_TIME_NOW, 0), NSEC_PER_SEC, 2*NSEC_PER_SEC);
        
        dispatch_source_set_event_handler(reloadMapTimer, {
            dispatch_async(dispatch_get_main_queue(), {
                print("ReloadMap")
                self.reloadMap()
            })
        });
        dispatch_resume(reloadMapTimer);
    }
    
    func nearbyCleaners(location:CLLocation){
            do{
                self.cleaners = try Cleaner.getNearbyCleaners(location.coordinate.latitude, longitud: location.coordinate.longitude, withToken: self.token)
            } catch Cleaner.Error.noSessionFound{
                createAlertInfo("Error con la sesion")
                while !self.clickedAlertOK {
                    
                }
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("main")
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(nextViewController, animated: true, completion: nil)
                })
            } catch {
                print("Error leyendo lavadores")
            }
    }
    
    func reloadMap(){
        do{
            if self.activeService != nil {
                if self.activeService.status != "Looking" {
                    self.cleaner = try Cleaner.getCleanerLocation(self.activeService.cleanerId,withToken: self.token)
                }
            }
        } catch Cleaner.Error.noSessionFound{
            print("Error")
            createAlertInfo("Error con la sesion")
            while !self.clickedAlertOK {
                
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("main")
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            print("Error leyendo ubicacion del lavador")
        }
        //TODO: check fo nil
        if activeService != nil {
            if activeService.status != "Looking" && cleaner != nil{
                cleanerMarker.map = map
                cleanerMarker.position = CLLocationCoordinate2D(latitude: cleaner.latitud, longitude: cleaner.longitud)
            }
        } else {
            cleanerMarker.map = nil
            requestLocation = CLLocation(latitude: centralMarker.position.latitude, longitude: centralMarker.position.longitude)
            if cleaners.count >= markers.count {
                addMarkersAndUpdate()
            } else {
                removeMarkersAndUpdate()
            }
        }
    }
    
    func addMarkersAndUpdate(){
        var aux = Array<GMSMarker>()
        var i = 0
        while cleaners.count > i {
            if markers.count > i {
                aux.append(markers[i])
                aux[i].map = map
            } else {
                aux.append(GMSMarker(position: CLLocationCoordinate2D(latitude: self.cleaners[i].latitud, longitude: self.cleaners[i].longitud)))
                aux[i].map = map
            }
            i += 1
        }
        markers = aux
    }
    
    func removeMarkersAndUpdate(){
        var aux = Array<GMSMarker>()
        var i = 0
        while cleaners.count > i {
            aux.append(markers[i])
            aux[i].position = CLLocationCoordinate2D(latitude: self.cleaners[i].latitud, longitude: self.cleaners[i].longitud)
            i += 1
        }
        while markers.count > i {
            markers[i].map = nil
            i += 1
        }
        markers = aux
    }
    
    func reloadAddress(location:CLLocation){
        if self.requestLocation != nil{
            let location = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    self.locationText.text = ""
                    return
                }
                
                if placemarks!.count > 0 {
                    //TODO:check for convert
                    let pm = placemarks![0]
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        //self.locationText.text = "\(pm.thoroughfare) \(pm.subThoroughfare), \(pm.subLocality), \(pm.locality), \(pm.administrativeArea)"
                        print(self.locationText.text)
                    });
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    func configureState(){
        switch viewState {
        case STANDBY:
            configureStandByState()
            setButtonVisibilityAll()
            break
        case VEHICLE_SELECTED:
            configureVehicleSelectedState()
            break
        case SERVICE_SELECTED:
            configureServiceSelectedState()
            break
        case SERVICE_TYPE_SELECTED:
            configureServiceTypeState()
            break
        case SERVICE_START:
            configureServiceStartState()
            viewState = -1
            break
        default:
            break
        }
    }
    
    func setButtonVisibilityAll(){
        bikeImage.hidden = false
        smallCarImage.hidden = false
        bigCarImage.hidden = false
        smallVanImage.hidden = false
        bigVanImage.hidden = false
    }
    
    func setButtonVisibility(i:Int){
        bikeImage.alpha = 0
        smallCarImage.alpha = 0
        bigCarImage.alpha = 0
        smallVanImage.alpha = 0
        bigVanImage.alpha = 0
        switch i {
        case 0:
            bikeImage.alpha = 1
        case 1:
            smallCarImage.alpha = 1
        case 2:
            bigCarImage.alpha = 1
        case 3:
            smallVanImage.alpha = 1
        case 4:
            bigVanImage.alpha = 1
        default: break
        }
    }
    
    func configureStandByState(){
        upLayoutHeight.constant = upLayoutSize
        lowLayoutHeight.constant = 0
        startLayoutHeight.constant = 0
        upLayout.hidden = false
        lowLayout.hidden = true
        startLayout.hidden = true
        //TODO: locationText.SetEnable
    }
    func configureVehicleSelectedState(){
        upLayoutHeight.constant = upLayoutSize
        lowLayoutHeight.constant = lowLayoutSize
        startLayoutHeight.constant = 0
        upLayout.hidden = false
        lowLayout.hidden = false
        startLayout.hidden = true
        leftButton.setTitle("Exterior", forState: .Normal)
        leftDescription.text = "Servicio Exterior"
        rightButton.setTitle("Exterior e Interior", forState: .Normal)
        rightDescription.text = "Servicio Exterior e Interior"
        //TODO: locationText.SetEnable
    }
    func configureServiceSelectedState(){
        upLayoutHeight.constant = upLayoutSize
        lowLayoutHeight.constant = lowLayoutSize
        startLayoutHeight.constant = 0
        upLayout.hidden = false
        lowLayout.hidden = false
        startLayout.hidden = true
        leftButton.setTitle("Eco $", forState: .Normal)
        leftDescription.text = "Servicio Ecologico"
        leftButton.setTitle("Tradicional $$", forState: .Normal)
        rightDescription.text = "Servicio Tradicional"
        //TODO: locationText.SetEnable
    }
    func configureServiceTypeState(){
        if serviceRequestFlag {
             return
         }
         serviceRequestFlag = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.sendRequestService()
        });
    }
    func configureServiceStartState(){
        upLayoutHeight.constant = 0
        lowLayoutHeight.constant = 0
        startLayoutHeight.constant = startLayoutSize
        upLayout.hidden = true
        lowLayout.hidden = true
        startLayout.hidden = false
        cancelButton.hidden = false
        serviceInfo.text = "Buscando Lavador"
        //TODO: locationText.SetEnable
        configureActiveServiceView()
    }
    
    func sendRequestService(){
        do{
            let favCar = DataBase.getFavoriteCar()!
            let serviceRequested = try Service.requestService("",withLatitud: String(requestLocation.coordinate.latitude),withLongitud: String(requestLocation.coordinate.longitude),withId: service,withType: serviceType,withToken: token,withCar: vehicleType, withFavoriteCar: favCar.id)
            var services:Array<Service> = DataBase.readServices()!
            services.append(serviceRequested)
            DataBase.saveServices(services)
            cancelCode = 0;
            activeService = serviceRequested
            dispatch_async(dispatch_get_main_queue(), {
                self.upLayoutHeight.constant = 0
                self.lowLayoutHeight.constant = 0
                self.startLayoutHeight.constant = self.startLayoutSize
                self.upLayout.hidden = true
                self.lowLayout.hidden = true
                self.startLayout.hidden = false
                self.cancelButton.hidden = false
                self.cleanerInfo.hidden = true
                //LocationTextSetEnable
                self.serviceInfo.text = "Buscando Lavador"
            })
            startActiveServiceCycle()
            cancelSent = false
        } catch Service.Error.noSessionFound{
            createAlertInfo("Error con la sesion")
            while !clickedAlertOK {
                
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("main")
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch Service.Error.userBlock{
            createAlertInfo("Usuario bloqueado por error de tarjeta")
            serviceRequestFlag = false
            onResume()
        } catch {
            createAlertInfo("Error pidiendo servicio")
            serviceRequestFlag = false
            onResume()
        }
    }
    
    func startActiveServiceCycle(){
        if activeServiceCycleThread == nil {
            activeServiceCycleThread = NSThread(target: self, selector:#selector(activeServiceCycle), object: nil)
            activeServiceCycleThread.start()
        } else if !activeServiceCycleThread.executing {
            activeServiceCycleThread = NSThread(target: self, selector:#selector(activeServiceCycle), object: nil)
            activeServiceCycleThread.start()
        }
    }
    
    func activeServiceCycle(){
        while DataBase.getActiveService() != nil {
            activeService = DataBase.getActiveService()
            configureActiveServiceView()
            while !AppData.newData(){}
        }
        activeService = nil
        configureServiceForDelete()
    }
    
    func configureActiveServiceView(){
        checkNotification()
        switch activeService.status {
        case "Looking":
            configureActiveServiceForLooking()
            break
        case "Accepted":
            var diffInMillis = NSDate().timeIntervalSinceDate(activeService.acceptedTime)
            if diffInMillis < 0 {
                diffInMillis = 0
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.cancelButton.hidden = false
                })
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(diffInMillis)), dispatch_get_main_queue(), {
                self.cancelButton.hidden = true
                });
            configureActiveService("Llegando en 15 min desde pedido")
            cancelAlarmClock = NSTimer.scheduledTimerWithTimeInterval(120, target: self, selector: #selector(MapController.alertForCancel), userInfo: nil, repeats: false)
    
            break
        case "On The Way":
            if cancelAlarmClock != nil {
                cancelAlarmClock.invalidate()
            }
            configureActiveService("De camino")
            break
        case "Started":
            dispatch_async(dispatch_get_main_queue(), {
                self.cancelButton.hidden = true
            })
            if cancelAlarmClock != nil {
                cancelAlarmClock.invalidate()
            }
            clock = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(MapController.modifyClock), userInfo: nil, repeats: true)
            break
        case "Finished":
            configureActiveServiceForFinished()
            break
        default:
            break
        }
        AppData.notifyNewData(false)
    }
    
    func configureServiceForDelete(){
        serviceRequestFlag = false
        dispatch_async(dispatch_get_main_queue(), {
            self.cleanerInfo.hidden = true
            self.cleanerImageInfo.hidden = true
            self.cleanerInfo.text = "-"
            self.cleanerImageInfo.image = nil
            self.serviceInfo.text = "Buscando lavador"
            self.onResume()
        })
    }
    
    func checkNotification(){
        let message = AppData.getMessage()
        if message != "" && message != "Finished"{
            AppData.deleteMessage()
            dispatch_async(dispatch_get_main_queue(), {
                self.createAlertInfo(message)
            })
        }
    }
    
    func configureActiveServiceForLooking(){
        dispatch_async(dispatch_get_main_queue(), {
            self.cleanerInfo.hidden = true
            self.cleanerImageInfo.hidden = true
            self.serviceInfo.text = "Buscando lavador"
            self.cancelButton.hidden = true
            if self.activeService != nil{
                self.centralMarker.position = CLLocationCoordinate2D(latitude: self.activeService.latitud, longitude: self.activeService.longitud)
            }
            for marker in self.markers {
                marker.map = nil
            }
        })
    }
    
    func configureActiveServiceForFinished(){
        if clock != nil {
            clock.invalidate()
        }
        if activeService.rating == -1 {
            cancelTimers()
            let storyBoard = UIStoryboard(name: "Map", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("summary") as! SummaryController
            self.presentViewController(nextViewController, animated: true, completion: nil)
        }
        serviceRequestFlag = false
        dispatch_async(dispatch_get_main_queue(), {
            self.cleanerInfo.hidden = true
            self.cleanerImageInfo.hidden = true
            self.cleanerInfo.text = "-"
            self.cleanerImageInfo.image = nil
            self.serviceInfo.text = "Buscando lavador"
        })
    }
    
    func modifyClock(){
        if activeService != nil && activeService.finalTime != nil {
            let diff = activeService.finalTime.timeIntervalSinceNow
            let minutes = Int(diff/60)
            var display = ""
            if diff < 0 {
                display = "Terminando servicio en: 0 min"
                clock.invalidate()
            } else {
                display = "Terminando servicio en: " + String(minutes + 1) + " min"
            }
            configureActiveService(display)
        }
    }
    
    func configureActiveService(display:String){
        dispatch_async(dispatch_get_main_queue(), {
            if self.activeService != nil{
                self.cleanerInfo.hidden = false
                self.cleanerImageInfo.hidden = false
                self.cleanerInfo.text = self.activeService.cleanerName
                self.serviceInfo.text = display
                self.centralMarker.position = CLLocationCoordinate2D(latitude: self.activeService.latitud, longitude: self.activeService.longitud)
            }
        })
        setImageDrawableForActiveService()
    }
    
    func setImageDrawableForActiveService(){
        let url = NSURL(string: "http://imanio.zone/Vashen/images/cleaners/" + activeService.cleanerId + "/profile_image.jpg")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let data = NSData(contentsOfURL: url!){
                dispatch_async(dispatch_get_main_queue(), {
                    self.cleanerImageInfo.image = UIImage(data: data)
                });
            }
        }
    }
    
    func alertForCancel(){
        dispatch_async(dispatch_get_main_queue(), {
            if self.activeService == nil || self.cancelSent{
                return
            }
            self.cancelCode = 2
            self.buildAlertForCancel()
            //Send notification
        })
    }
    
    func buildAlertForCancel(){
        if cancelCode == 2 {
            let alert = UIAlertController(title: "Lavador esta tomando mucho tiempo", message: "Deseas cancelar?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                self.sendCancel()
                if self.cancelAlarmClock != nil {
                    self.cancelAlarmClock.invalidate()
                }
            }))
            alert.addAction(UIAlertAction(title: "Esperar", style: UIAlertActionStyle.Default, handler: { action in
                if self.cancelAlarmClock != nil {
                    self.cancelAlarmClock.invalidate()
                }
                self.cancelAlarmClock = NSTimer.scheduledTimerWithTimeInterval(120, target: self, selector: #selector(MapController.alertForCancel), userInfo: nil, repeats: false)
                
            }))
        } else {
            let alert = UIAlertController(title: "Cancelar", message: "Cancelar en este momento incluye un costo extra, estas seguro...?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
                self.sendCancel()
                if self.cancelAlarmClock != nil {
                    self.cancelAlarmClock.invalidate()
                }
            }))
            alert.addAction(UIAlertAction(title: "Esperar", style: UIAlertActionStyle.Default, handler: nil))
        }
        
    }
    
    func sendCancel(){
        do {
            if cancelSent {
                return
            }
            cancelSent = true
            try Service.cancelService(activeService.id,withToken: token,withTimeOutCancel: cancelCode)
            
            activeService.status = "Canceled"
            var services = DataBase.readServices()
            let index = services?.indexOf({$0.id == activeService.id})
            services?.removeAtIndex(index!)
            AppData.notifyNewData(true)
            if cancelAlarmClock != nil {
                cancelAlarmClock.invalidate()
            }
        } catch Service.Error.noSessionFound{
            cancelSent = false
            createAlertInfo("Error de sesion")
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("main")
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(nextViewController, animated: true, completion: nil)
            })
        } catch {
            createAlertInfo("Error al cancelar")
            cancelSent = false
        }
    }
    
    
    @IBAction func leftClick(sender: AnyObject) {
        if viewState == VEHICLE_SELECTED {
            service = String(Service.OUTSIDE)
            viewState = SERVICE_SELECTED
        } else {
            serviceType = String(Service.ECO)
            viewState = SERVICE_TYPE_SELECTED
        }
        configureState()
    }
    
    @IBAction func rightClick(sender: AnyObject) {
        if viewState == VEHICLE_SELECTED {
            service = String(Service.OUTSIDE_INSIDE)
            viewState = SERVICE_SELECTED
        } else {
            serviceType = String(Service.TRADITIONAL)
            viewState = SERVICE_TYPE_SELECTED
        }
        configureState()
    }
    
    @IBAction func vehicleClicked(sender: UIButton) {
        do{
            if viewState != STANDBY {
                return
            }
            if creditCard == nil {
                createAlertInfo("Agrega una tarjeta de credito")
                return
            }
            if cleaners.count < 1 {
                createAlertInfo("No hay lavadores cercanos")
                return
            }
            viewState = VEHICLE_SELECTED
            try configureVehicleButtons(sender)
            configureState()
        } catch {
            createAlertInfo("Vehiculo invalido")
        }
    }
    
    func configureVehicleButtons(sender: UIButton) throws{
        var i:Int!
        switch sender {
        case bikeImage:
            i = 0
            vehicleType = String(Service.BIKE)
        case smallCarImage:
            i = 1
            vehicleType = String(Service.SMALL_CAR)
        case bigCarImage:
            i = 2
            vehicleType = String(Service.BIG_CAR)
        case smallVanImage:
            i = 3
            vehicleType = String(Service.SMALL_VAN)
        case bigVanImage:
            i = 4
            vehicleType = String(Service.BIG_VAN)
        default:
            throw Error.invalidVehicle
        }
        setButtonVisibility(i)
    }
    
    
    func initLocation(){
        self.locManager.requestAlwaysAuthorization()
        self.locManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = manager.location
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locManager.stopUpdatingLocation()
                print(error)
    }
    
    func initView(){
        menuOpenButton.target = self.revealViewController()
        menuOpenButton.action = #selector(SWRevealViewController.revealToggle(_:))       
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func initMap(){
        dispatch_async(dispatch_get_main_queue(), {
            var camera = GMSCameraPosition.cameraWithLatitude(0, longitude: 0, zoom: 15.0)
            self.map = GMSMapView.mapWithFrame(self.mapView.bounds, camera: camera)
            self.map.delegate = self
            self.map.myLocationEnabled = true
            self.map.accessibilityElementsHidden = false
            self.mapView.addSubview(self.map)
            
            if self.userLocation != nil {
                camera = GMSCameraPosition.cameraWithLatitude(self.userLocation.coordinate.latitude, longitude: self.userLocation.coordinate.longitude, zoom: 15.0)
            } else if self.map.myLocation != nil{
                camera = GMSCameraPosition.cameraWithLatitude(self.map.myLocation!.coordinate.latitude, longitude: self.map.myLocation!.coordinate.longitude, zoom: 15.0)
            }
            
            //self.view.sendSubviewToBack(self.mapView)
            self.map.camera = camera
            
            // Creates a marker in the center of the map.
            self.centralMarker.position = CLLocationCoordinate2D(latitude: camera.target.latitude, longitude: camera.target.longitude)
            self.requestLocation = CLLocation(latitude: self.centralMarker.position.latitude, longitude: self.centralMarker.position.longitude)
            self.centralMarker.map = self.map
        });
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        if activeService == nil{
            centralMarker.position = CLLocationCoordinate2D(latitude: position.target.latitude, longitude: position.target.longitude)
            //TODO: change to send geocoder async in xs time
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.reloadAddress(self.requestLocation)
            });
        }
    }
    
    @IBAction func myLocationClicked(sender: AnyObject) {
        var camera:GMSCameraPosition
        if self.userLocation == nil {
            camera = GMSCameraPosition.cameraWithLatitude(0, longitude: 0, zoom: 15.0)
        } else {
            camera = GMSCameraPosition.cameraWithLatitude(self.userLocation.coordinate.latitude, longitude: self.userLocation.coordinate.longitude, zoom: 15.0)
        }
        self.map.animateToCameraPosition(camera)
    }
    
    func createAlertInfo(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {action in
            self.clickedAlertOK = true
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    enum Error: ErrorType{
        case invalidVehicle
    }
}
