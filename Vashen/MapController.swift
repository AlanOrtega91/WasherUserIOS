//
//  MapController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit
import GoogleMaps

class MapController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var menuOpenButton: UIBarButtonItem!
    
    @IBOutlet weak var mapView: UIView!
    var map: GMSMapView!
    
    
    @IBOutlet weak var upLayout: UIView!
    @IBOutlet weak var upLayoutHeight: NSLayoutConstraint!
    let upLayoutSize = CGFloat(50)
    @IBOutlet weak var lowLayout: UIView!
    @IBOutlet weak var lowLayoutHeight: NSLayoutConstraint!
    let lowLayoutSize = CGFloat(150)
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


    @IBOutlet weak var vehiclesButton: UIButton!
    @IBOutlet weak var locationText: UITextField!

    
    var geoLocationQueue = DispatchQueue(label: "com.alan.geoLocation", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
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
    var activeServiceCycleThread:Thread!
    var cancelAlarmClock:DispatchSourceTimer!
    var clock:DispatchSourceTimer!
    var nearbyCleanersTimer:DispatchSourceTimer!
    var reloadMapTimer:DispatchSourceTimer!
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            self.initMap()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        inScope = false
        cancelTimers()
    }
    
    func cancelTimers(){
        if nearbyCleanersTimer != nil {
            nearbyCleanersTimer.cancel()
        }
        if reloadMapTimer != nil {
            reloadMapTimer.cancel()
        }
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
            viewState = SERVICE_START
            configureState()
            
        } else {
            viewState = SERVICE_START
            configureState()
            startActiveServiceCycle()
        }
    }
    
    func configureServices(){
        vehiclesButton.alpha = 0.5
        vehiclesButton.isUserInteractionEnabled = false
        
        var type = 6
        let selectedCar = DataBase.getFavoriteCar()
        if selectedCar != nil {
            type = Int(selectedCar!.type)!
        }
        
        switch type {
        case Service.BIKE:
            vehiclesButton.alpha = 1
            vehiclesButton.isUserInteractionEnabled = true
            vehiclesButton.setImage(UIImage(named: "bikeActive") , for: .normal)
        case Service.SMALL_CAR:
            vehiclesButton.alpha = 1
            vehiclesButton.isUserInteractionEnabled = true
            vehiclesButton.setImage(UIImage(named: "smallCarActive") , for: .normal)
        case Service.BIG_CAR:
            vehiclesButton.alpha = 1
            vehiclesButton.isUserInteractionEnabled = true
            vehiclesButton.setImage(UIImage(named: "bigCarActive") , for: .normal)
        case Service.SMALL_VAN:
            vehiclesButton.alpha = 1
            vehiclesButton.isUserInteractionEnabled = true
            vehiclesButton.setImage(UIImage(named: "smallVanActive") , for: .normal)
        case Service.BIG_VAN:
            vehiclesButton.alpha = 1
            vehiclesButton.isUserInteractionEnabled = true
            vehiclesButton.setImage(UIImage(named: "bigVanActive") , for: .normal)
        default:
            break
        }
    }
    
    func initTimers(){
        let nearbyCleanersQueue = DispatchQueue(label: "com.alan.nearbyCleaners", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        nearbyCleanersTimer = DispatchSource.makeTimerSource(flags: .strict, queue: nearbyCleanersQueue)
        nearbyCleanersTimer.scheduleRepeating(deadline: .now(), interval: .seconds(1), leeway: .seconds(2))
        nearbyCleanersTimer.setEventHandler(handler: {
            let tempLocation = self.requestLocation
            if self.activeService == nil && self.requestLocation != nil {
                DispatchQueue.main.async {
                    self.nearbyCleaners(location: tempLocation!)
                }
            }
        })
        nearbyCleanersTimer.resume()
        
        
        let reloadMapQueue = DispatchQueue(label: "com.alan.reloadMap", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        reloadMapTimer = DispatchSource.makeTimerSource(flags: .strict, queue: reloadMapQueue)
        reloadMapTimer.scheduleRepeating(deadline: .now(), interval: .seconds(1), leeway: .seconds(2))
        reloadMapTimer.setEventHandler(handler: {
                DispatchQueue.main.async {
                    self.reloadMap()
            }
        })
        reloadMapTimer.resume()
    }
    
    func nearbyCleaners(location:CLLocation){
            do{
                self.cleaners = try Cleaner.getNearbyCleaners(latitud: location.coordinate.latitude, longitud: location.coordinate.longitude, withToken: self.token)
            } catch Cleaner.CleanerError.noSessionFound{
                createAlertInfo(message: "Error con la sesion")
                while !self.clickedAlertOK {
                    
                }
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
                self.present(nextViewController, animated: true, completion: nil)
            } catch {
                print("Error leyendo lavadores")
            }
    }
    
    func reloadMap(){
        do{
            if self.activeService != nil {
                if self.activeService.status != "Looking" {
                    self.cleaner = try Cleaner.getCleanerLocation(cleanerId: self.activeService.cleanerId,withToken: self.token)
                }
            }
        } catch Cleaner.CleanerError.noSessionFound{
            print("Error")
            createAlertInfo(message: "Error con la sesion")
            while !self.clickedAlertOK {
                
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            self.present(nextViewController, animated: true, completion: nil)
        } catch {
            print("Error leyendo ubicacion del lavador")
        }
        //TODO: check fo nil
        if activeService != nil {
            if activeService.status != "Looking" && cleaner != nil{
                cleanerMarker.map = map
                cleanerMarker.position = CLLocationCoordinate2D(latitude: cleaner.latitud, longitude: cleaner.longitud)
                cleanerMarker.icon = UIImage(named: "washer")
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
                aux[i].icon = UIImage(named: "washer")
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
                    let pm = placemarks![0]
                    DispatchQueue.main.async {
                        if pm.thoroughfare != nil && pm.subThoroughfare != nil && pm.subLocality != nil && pm.locality != nil && pm.administrativeArea != nil {
                            self.locationText.text = "\(pm.thoroughfare!) \(pm.subThoroughfare!), \(pm.subLocality!), \(pm.locality!), \(pm.administrativeArea!)"
                        }
                        print(self.locationText.text)
                    }
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
    
    func configureStandByState(){
        upLayoutHeight.constant = upLayoutSize
        lowLayoutHeight.constant = 0
        startLayoutHeight.constant = 0
        upLayout.isHidden = false
        lowLayout.isHidden = true
        startLayout.isHidden = true
        //TODO: locationText.SetEnable
    }
    func configureVehicleSelectedState(){
        upLayoutHeight.constant = upLayoutSize
        lowLayoutHeight.constant = lowLayoutSize
        startLayoutHeight.constant = 0
        upLayout.isHidden = false
        lowLayout.isHidden = false
        startLayout.isHidden = true
        leftButton.setTitle("Lavado Exterior $$", for: .normal)
        leftButton.setImage(UIImage(named: "exterior"), for: .normal)
        leftDescription.text = "Consiste en lavado de carrocería, cris- tales, rines, llantas y molduras (no se requiere estar en el lugar de servicio del vehículo)."
        rightButton.setTitle("Lavado Interior $$", for: .normal)
        rightButton.setImage(UIImage(named: "interior"), for: .normal)
        rightDescription.text = "Consiste en Lavado de carrocería, cristales, rines, llantas, molduras, aspirado y limpieza de habitáculo (se requiere estar presente al momento de iniciar y al terminar el servicio para permitir que el socio lavador pueda acceder al interior del vehículo)."
        //TODO: locationText.SetEnable
    }
    func configureServiceSelectedState(){
        upLayoutHeight.constant = upLayoutSize
        lowLayoutHeight.constant = lowLayoutSize
        startLayoutHeight.constant = 0
        upLayout.isHidden = false
        lowLayout.isHidden = false
        startLayout.isHidden = true
        leftButton.setTitle("Ecologico $$", for: .normal)
        leftButton.setImage(UIImage(named: "ecologico"), for: .normal)
        leftDescription.text = "Lavado de auto en seco, con nuestro producto de máxima calidad, que brinda un acabado brillante, sin rayar el auto, protegiendo la pintura, al mismo tiempo que deja una capa de cera protectora."
        rightButton.setTitle("Tradicional $$", for: .normal)
        rightButton.setImage(UIImage(named: "tradicional"), for: .normal)
        rightDescription.text = "Lavado de auto con agua y shampoo, que deja una capa protectora de cera. Para este servicio, el usuario deberá proporcionar el agua al momento de la llegada de nuestros socios lavadores."
        //TODO: locationText.SetEnable
    }
    func configureServiceTypeState(){
        if serviceRequestFlag {
             return
         }
         serviceRequestFlag = true
        DispatchQueue.global(qos: .background).async {
            self.sendRequestService()
        }
    }
    func configureServiceStartState(){
        upLayoutHeight.constant = 0
        lowLayoutHeight.constant = 0
        startLayoutHeight.constant = startLayoutSize
        upLayout.isHidden = true
        lowLayout.isHidden = true
        startLayout.isHidden = false
        cancelButton.isHidden = false
        serviceInfo.text = "Buscando Lavador"
        //TODO: locationText.SetEnable
        configureActiveServiceView()
    }
    
    func sendRequestService(){
        do{
            let favCar = DataBase.getFavoriteCar()!
            let serviceRequested = try Service.requestService(direccion: "",withLatitud: String(requestLocation.coordinate.latitude),withLongitud: String(requestLocation.coordinate.longitude),withId: service,withType: serviceType,withToken: token,withCar: vehicleType, withFavoriteCar: favCar.id)
            var services:Array<Service> = DataBase.readServices()!
            services.append(serviceRequested)
            DataBase.saveServices(services: services)
            cancelCode = 0;
            activeService = serviceRequested
            DispatchQueue.main.async {
                self.upLayoutHeight.constant = 0
                self.lowLayoutHeight.constant = 0
                self.startLayoutHeight.constant = self.startLayoutSize
                self.upLayout.isHidden = true
                self.lowLayout.isHidden = true
                self.startLayout.isHidden = false
                self.cancelButton.isHidden = false
                self.cleanerInfo.isHidden = true
                //LocationTextSetEnable
                self.serviceInfo.text = "Buscando Lavador"
            }
            startActiveServiceCycle()
            cancelSent = false
        } catch Service.ServiceError.noSessionFound{
            createAlertInfo(message: "Error con la sesion")
            while !clickedAlertOK {
                
            }
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            DispatchQueue.main.async {
                self.present(nextViewController, animated: true, completion: nil)
            }
        } catch Service.ServiceError.userBlock{
            createAlertInfo(message: "Usuario bloqueado por error de tarjeta")
            serviceRequestFlag = false
            onResume()
        } catch {
            createAlertInfo(message: "Error pidiendo servicio")
            serviceRequestFlag = false
            onResume()
        }
    }
    
    func startActiveServiceCycle(){
        if activeServiceCycleThread == nil {
            activeServiceCycleThread = Thread(target: self, selector:#selector(activeServiceCycle), object: nil)
            activeServiceCycleThread.start()
        } else if !activeServiceCycleThread.isExecuting {
            activeServiceCycleThread = Thread(target: self, selector:#selector(activeServiceCycle), object: nil)
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
            var diffInMillis = activeService.acceptedTime.addingTimeInterval(60 * 2).timeIntervalSinceNow
            if diffInMillis < 0 {
                diffInMillis = 0
            } else {
                DispatchQueue.main.async {
                    self.cancelButton.isHidden = false
                }
            }
            cancelCode = 1
            //TODO: Check this
            let t = DispatchTime.now() + diffInMillis
            DispatchQueue.main.asyncAfter(deadline: t, execute: {
                self.cancelButton.isHidden = true
                });
            configureActiveService(display: "Llegando en: 15 min")
            
            let cancelAlarmClockQueue = DispatchQueue(label: "com.alan.clockCancel", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
            cancelAlarmClock = DispatchSource.makeTimerSource(flags: .strict, queue: cancelAlarmClockQueue)
            cancelAlarmClock.scheduleRepeating(deadline: .now() + .seconds(60*15), interval: .seconds(60*15), leeway: .seconds(60))
            cancelAlarmClock.setEventHandler(handler: {
                DispatchQueue.main.async {
                    self.alertForCancel()
                }
            })
            cancelAlarmClock.resume()
            
    
            break
        case "On The Way":
            if cancelAlarmClock != nil {
                cancelAlarmClock.cancel()
            }
            configureActiveService(display: "De camino")
            break
        case "Started":
            DispatchQueue.main.async {
                self.cancelButton.isHidden = true
            }
            if cancelAlarmClock != nil {
                cancelAlarmClock.cancel()
            }
            
            let clockQueue = DispatchQueue(label: "com.alan.clock", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
            clock = DispatchSource.makeTimerSource(flags: .strict, queue: clockQueue)
            clock.scheduleRepeating(deadline: .now(), interval: .seconds(1), leeway: .seconds(2))
            clock.setEventHandler(handler: {
                DispatchQueue.main.async {
                    self.modifyClock()
                }
            })
            clock.resume()
            
            break
        case "Finished":
            configureActiveServiceForFinished()
            break
        default:
            break
        }
        AppData.notifyNewData(newData: false)
    }
    
    func configureServiceForDelete(){
        serviceRequestFlag = false
        DispatchQueue.main.async {
            self.cleanerInfo.isHidden = true
            self.cleanerImageInfo.isHidden = true
            self.cleanerInfo.text = "-"
            self.cleanerImageInfo.image = nil
            self.serviceInfo.text = "Buscando lavador"
            self.onResume()
        }
    }
    
    func checkNotification(){
        let message = AppData.getMessage()
        if message != "" && message != "Finished"{
            AppData.deleteMessage()
            DispatchQueue.main.async {
                self.createAlertInfo(message: message)
            }
        }
    }
    
    func configureActiveServiceForLooking(){
        DispatchQueue.main.async {
            self.cleanerInfo.isHidden = true
            self.cleanerImageInfo.isHidden = true
            self.serviceInfo.text = "Buscando lavador"
            self.cancelButton.isHidden = false
            if self.activeService != nil{
                self.centralMarker.position = CLLocationCoordinate2D(latitude: self.activeService.latitud, longitude: self.activeService.longitud)
            }
            for marker in self.markers {
                marker.map = nil
            }
        }
    }
    
    func configureActiveServiceForFinished(){
        if clock != nil {
            clock.cancel()
        }
        if activeService.rating == -1 {
            cancelTimers()
            let storyBoard = UIStoryboard(name: "Map", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "summary") as! SummaryController
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
        serviceRequestFlag = false
        DispatchQueue.main.async {
            self.cleanerInfo.isHidden = true
            self.cleanerImageInfo.isHidden = true
            self.cleanerInfo.text = "-"
            self.cleanerImageInfo.image = nil
            self.serviceInfo.text = "Buscando lavador"
        }
    }
    
    func modifyClock(){
        if activeService != nil && activeService.finalTime != nil {
            let diff = activeService.finalTime.timeIntervalSinceNow
            let minutes = Int(diff/60)
            var display = ""
            if diff < 0 {
                display = "Tu servicio terminara en cualquier momento"
                clock.cancel()
            } else {
                display = "Terminando servicio en: " + String(minutes + 1) + " min"
            }
            configureActiveService(display: display)
        }
    }
    
    func configureActiveService(display:String){
        DispatchQueue.main.async {
            if self.activeService != nil{
                self.cleanerInfo.isHidden = false
                self.cleanerImageInfo.isHidden = false
                self.cleanerInfo.text = self.activeService.cleanerName
                self.serviceInfo.text = display
                self.centralMarker.position = CLLocationCoordinate2D(latitude: self.activeService.latitud, longitude: self.activeService.longitud)
            }
        }
        setImageDrawableForActiveService()
    }
    
    func setImageDrawableForActiveService(){
        let url = NSURL(string: "http://imanio.zone/Vashen/images/cleaners/" + activeService.cleanerId + "/profile_image.jpg")
        do {
            let data = try Data(contentsOf: url as! URL)
            self.cleanerImageInfo.image = UIImage(data: data as Data)
        } catch {}
    }
    
    func alertForCancel(){
            if self.activeService == nil || self.cancelSent{
                return
            }
            self.cancelCode = 2
            self.buildAlertForCancel()
            //Send notification
    }
    
    func buildAlertForCancel(){
        cancelAlarmClock.suspend()
        var alert:UIAlertController!
        if cancelCode == 2 {
            alert = UIAlertController(title: "Lavador esta tomando mucho tiempo", message: "Deseas cancelar?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                self.sendCancel()
            }))
            alert.addAction(UIAlertAction(title: "Esperar", style: UIAlertActionStyle.default, handler: { action in
                self.cancelAlarmClock.resume()
            }))
        } else {
            alert = UIAlertController(title: "Cancelar", message: "Cancelar en este momento incluye un costo extra, estas seguro...?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                self.sendCancel()
                if self.cancelAlarmClock != nil {
                    self.cancelAlarmClock.cancel()
                }
            }))
            alert.addAction(UIAlertAction(title: "Esperar", style: UIAlertActionStyle.default, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func clickCancel(_ sender: AnyObject) {
        if cancelCode == 0 {
            sendCancel()
        } else if cancelCode == 1 {
            buildAlertForCancel()
        }
    }
    func sendCancel(){
        do {
            if cancelSent {
                return
            }
            cancelSent = true
            try Service.cancelService(idService: activeService.id,withToken: token,withTimeOutCancel: cancelCode)
            
            activeService.status = "Canceled"
            var services = DataBase.readServices()
            let index = services?.index(where: {$0.id == activeService.id})
            services?.remove(at: index!)
            DataBase.saveServices(services: services!)
            AppData.notifyNewData(newData: true)
            if cancelAlarmClock != nil {
                cancelAlarmClock.cancel()
            }
        } catch Service.ServiceError.noSessionFound{
            cancelSent = false
            createAlertInfo(message: "Error de sesion")
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            DispatchQueue.main.async {
                self.present(nextViewController, animated: true, completion: nil)
            }
        } catch {
            createAlertInfo(message: "Error al cancelar")
            cancelSent = false
            if cancelAlarmClock != nil {
                cancelAlarmClock.resume()
            }
        }
    }
    
    
    @IBAction func leftClick(_ sender: AnyObject) {
        if viewState == VEHICLE_SELECTED {
            service = String(Service.OUTSIDE)
            viewState = SERVICE_SELECTED
        } else {
            serviceType = String(Service.ECO)
            viewState = SERVICE_TYPE_SELECTED
        }
        configureState()
    }
    
    @IBAction func rightClick(_ sender: AnyObject) {
        if viewState == VEHICLE_SELECTED {
            service = String(Service.OUTSIDE_INSIDE)
            viewState = SERVICE_SELECTED
        } else {
            serviceType = String(Service.TRADITIONAL)
            viewState = SERVICE_TYPE_SELECTED
        }
        configureState()
    }
    
    @IBAction func vehicleClicked(_ sender: UIButton) {
            if viewState != STANDBY {
                return
            }
            if creditCard == nil {
                createAlertInfo(message: "Agrega una tarjeta de credito")
                return
            }
            if cleaners.count < 1 {
                createAlertInfo(message: "No hay lavadores cercanos")
                return
            }
            viewState = VEHICLE_SELECTED
            vehicleType = DataBase.getFavoriteCar()?.type
            configureState()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = manager.location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.locationServicesEnabled() {
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager.startUpdatingLocation()
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.0, execute: {
                self.myLocationClicked("" as AnyObject)
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locManager.stopUpdatingLocation()
                print(error)
    }
    
    func initView(){
        menuOpenButton.target = self.revealViewController()
        menuOpenButton.action = #selector(SWRevealViewController.revealToggle(_:))       
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.locationText.delegate = self
    }
    
    func initMap(){
            var camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15.0)
            self.map = GMSMapView.map(withFrame: self.mapView.bounds, camera: camera)
            self.map.delegate = self
            self.map.isMyLocationEnabled = true
            self.map.accessibilityElementsHidden = false
            self.mapView.addSubview(self.map)
            
            if self.userLocation != nil {
                camera = GMSCameraPosition.camera(withLatitude: self.userLocation.coordinate.latitude, longitude: self.userLocation.coordinate.longitude, zoom: 15.0)
            } else if self.map.myLocation != nil{
                camera = GMSCameraPosition.camera(withLatitude: self.map.myLocation!.coordinate.latitude, longitude: self.map.myLocation!.coordinate.longitude, zoom: 15.0)
            }
            
            //self.view.sendSubviewToBack(self.mapView)
            self.map.camera = camera
            
            // Creates a marker in the center of the map.
            self.centralMarker.position = CLLocationCoordinate2D(latitude: camera.target.latitude, longitude: camera.target.longitude)
            self.requestLocation = CLLocation(latitude: self.centralMarker.position.latitude, longitude: self.centralMarker.position.longitude)
            self.centralMarker.map = self.map
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.view.endEditing(true)
        if activeService == nil{
            centralMarker.position = CLLocationCoordinate2D(latitude: position.target.latitude, longitude: position.target.longitude)
            self.locationText.text = ""
            geoLocationQueue.suspend()
            geoLocationQueue.asyncAfter(deadline: .now() + 2, execute: {
                self.reloadAddress(location: self.requestLocation)
            })
            geoLocationQueue.resume()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        self.view.endEditing(true)
    }
    
    @IBAction func myLocationClicked(_ sender: AnyObject) {
        var camera:GMSCameraPosition
        if self.userLocation == nil {
            camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15.0)
        } else {
            camera = GMSCameraPosition.camera(withLatitude: self.userLocation.coordinate.latitude, longitude: self.userLocation.coordinate.longitude, zoom: 15.0)
        }
        self.map.animate(to: camera)
    }
    
    func createAlertInfo(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {action in
            self.clickedAlertOK = true
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        DispatchQueue.global().async {
            self.modifyLocation()
        }
        return true
    }
    
    func modifyLocation(){
        CLGeocoder().geocodeAddressString(self.locationText.text!, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
            } else if let placemark = placemarks?[0]{
                let camera = GMSCameraPosition.camera(withLatitude: (placemark.location?.coordinate.latitude)!, longitude: (placemark.location?.coordinate.longitude)!, zoom: 15.0)
                self.map.animate(to: camera)
            }
            
        })

    }
}
