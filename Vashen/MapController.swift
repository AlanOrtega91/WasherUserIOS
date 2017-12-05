//
//  MapController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,SWRevealViewControllerDelegate {
    
    @IBOutlet weak var menuOpenButton: UIBarButtonItem!
    
    @IBOutlet weak var mapViewIOS: MKMapView!
    
    @IBOutlet weak var upLayout: UIView!
    @IBOutlet weak var upLayoutHeight: NSLayoutConstraint!
    let upLayoutSize = CGFloat(70)
    @IBOutlet weak var lowLayout: UIView!
    @IBOutlet weak var lowLayoutHeight: NSLayoutConstraint!
    let lowLayoutSize = CGFloat(160)
    @IBOutlet weak var startLayout: UIView!
    @IBOutlet weak var startLayoutHeight: NSLayoutConstraint!
    let startLayoutSize = CGFloat(90)
    
    @IBOutlet weak var serviceInfo: UILabel!
    @IBOutlet weak var cleanerInfo: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var cleanerImageInfo: UIImageView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var leftDescriptionLeft: UILabel!
    @IBOutlet weak var rightDescriptionView: UIView!
    
    
    @IBOutlet weak var vehiclesButton: UIButton!
    @IBOutlet weak var locationText: UITextField!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var metodoDePagoTexto: UIButton!
    
   
    
    var geoLocationQueue = DispatchQueue(label: "com.alan.geoLocation", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    var locManager = CLLocationManager()
    var cleaners: [Cleaner] = []
    
    var idClient:String!
    var token:String!
    var user: User!
    var creditCard: UserCard!
    var activeService: Service!
    var viewState = Int()
    final var STANDBY = 0
    final var VEHICLE_SELECTED = 1
    final var OUTSIDE_OR_INSIDE_SELECTED = 2
    final var SERVICE_START = 3
    var serviceRequestFlag: Bool = false
    var requestLocation: CLLocation!
    var vehicleType:String!
    var service:String!
    var cancelCode:Int = 0
    var cancelSent:Bool = false
    var activeServiceCycleThread = DispatchQueue(label: "com.washer.activeServiceCycle", attributes: .concurrent)
    var running = false
    var cancelAlarmClock:DispatchSourceTimer!
    var clock:DispatchSourceTimer!
    var nearbyCleanersTimer:DispatchSourceTimer!
    var reloadMapTimer:DispatchSourceTimer!
    
    let centralMarker = CustomCentralMarker()
    let cleanerMarker = CustomCleanerMarker()
    var markers: [CustomCleanerMarker] = []
    var cleaner:Cleaner!
    var showCancelAlert:Bool = false
    var userLocation: CLLocation!
    var inScope:Bool = false
    
    var clickedAlertOK = false
    var menuOpen = false
    var cleanerMarkerAnnotationAdded = false
    var alert:UIAlertController!
    
    let normalLeftText = " -Carrocería\n -Rines"
    let bikeLeftText = " -Carrocería\n -Rines\n -Asiento"
    var metodoDePago:String = "t"
    
    var precios = [Precio]()
    var idRegion = 0
    
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
        viewState = SERVICE_START
        if activeService == nil {
            viewState = STANDBY
            configureState()
        } else if activeService.status == "Finished" {
            configureActiveServiceView()
        } else {
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
            vehiclesButton.setImage(UIImage(named: "bike_active") , for: .normal)
        case Service.CAR:
            vehiclesButton.alpha = 1
            vehiclesButton.isUserInteractionEnabled = true
            vehiclesButton.setImage(UIImage(named: "car_active") , for: .normal)
        case Service.SMALL_VAN:
            vehiclesButton.alpha = 1
            vehiclesButton.isUserInteractionEnabled = true
            vehiclesButton.setImage(UIImage(named: "small_van_active") , for: .normal)
        case Service.BIG_VAN:
            vehiclesButton.alpha = 1
            vehiclesButton.isUserInteractionEnabled = true
            vehiclesButton.setImage(UIImage(named: "big_van_active") , for: .normal)
        default:
            break
        }
    }
    
    func initTimers(){
        let nearbyCleanersQueue = DispatchQueue(label: "com.alan.nearbyCleaners", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        nearbyCleanersTimer = DispatchSource.makeTimerSource(flags: .strict, queue: nearbyCleanersQueue)
        nearbyCleanersTimer.scheduleRepeating(deadline: .now(), interval: .milliseconds(50), leeway: .seconds(1))
        nearbyCleanersTimer.setEventHandler(handler: {

            self.leeYDibujaLavadores()
        })
        nearbyCleanersTimer.resume()
    }
    
    func leeYDibujaLavadores()
    {
        if self.activeService != nil &&  self.activeService.status != "Looking" {
            readCleanerLocation()
            actualizaMarcadorDeLavador()
        } else if requestLocation != nil {
            getNearbyCleaners()
            actualizaMarcadorDeLavadores()
        }
    }
    
    func readCleanerLocation()
    {
        do{
            self.cleaner = try Cleaner.getCleanerLocation(cleanerId: self.activeService.cleanerId,withToken: self.token)
        } catch Cleaner.CleanerError.errorGettingCleaners {
            print("Error leyendo ubicacion del lavador")
        } catch Cleaner.CleanerError.noSessionFound {
            ProfileReader.delete()
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            self.navigationController?.setViewControllers([nextViewController], animated: true)
            _ = self.navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error leyendo lavador")
        }
    }
    
    func getNearbyCleaners()
    {
        do{
            self.cleaners = try Cleaner.getNearbyCleaners(latitud: self.requestLocation.coordinate.latitude, longitud: self.requestLocation.coordinate.longitude, withToken: self.token)
        } catch Cleaner.CleanerError.noSessionFound{
            ProfileReader.delete()
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            self.navigationController?.setViewControllers([nextViewController], animated: true)
            _ = self.navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error leyendo lavadores")
        }
    }
    
    func actualizaMarcadorDeLavador()
    {
        DispatchQueue.main.async {
        if self.activeService.status != "Looking" && self.cleaner != nil {
            if self.cleaner.latitud != nil && self.cleaner.longitud != nil {
                if !self.cleanerMarkerAnnotationAdded {
                    self.mapViewIOS.addAnnotation(self.cleanerMarker)
                    self.cleanerMarkerAnnotationAdded = true
                }
                let ubicacionLavador = CLLocationCoordinate2D(latitude: self.cleaner.latitud, longitude: self.cleaner.longitud)
                if self.cleanerMarker.coordinate.latitude != ubicacionLavador.latitude ||  self.cleanerMarker.coordinate.longitude != ubicacionLavador.longitude{
                    self.cleanerMarker.coordinate = ubicacionLavador
                }
            }
        } else {
            self.mapViewIOS.removeAnnotations(self.markers)
            self.markers.removeAll()
        }
        }
    }
    
    func actualizaMarcadorDeLavadores()
    {
        DispatchQueue.main.async {
            if self.cleanerMarkerAnnotationAdded {
                self.mapViewIOS.removeAnnotation(self.cleanerMarker)
                self.cleanerMarkerAnnotationAdded = false
            }
            if self.cleaners.count >= self.markers.count {
                self.addMarkersAndUpdate()
            } else {
                self.removeMarkersAndUpdate()
            }
        }
    }
    
    
    func addMarkersAndUpdate(){
        var agregarACambio = false
        var marcadoresACambiar: [CustomCleanerMarker] = []
        
        var i = 0
        while cleaners.count > i {
            agregarACambio = false
            if markers.count > i {
                
                let ubicacionLavador = CLLocationCoordinate2D(latitude: self.cleaners[i].latitud, longitude: self.cleaners[i].longitud)
                if markers[i].coordinate.latitude != ubicacionLavador.latitude ||  markers[i].coordinate.longitude != ubicacionLavador.longitude{
                    markers[i].coordinate = ubicacionLavador
                    //agregarACambio = true
                }
                
                
                if self.cleaners[i].ocupado {
                    if !markers[i].ocupado {
                        markers[i].ocupado = true
                        agregarACambio = true
                    }
                } else {
                    if markers[i].ocupado {
                        markers[i].ocupado = false
                        agregarACambio = true
                    }
                }
                if agregarACambio {
                    marcadoresACambiar.append(markers[i])
                }
            } else {
                let newMarker = CustomCleanerMarker()
                newMarker.coordinate = CLLocationCoordinate2D(latitude: self.cleaners[i].latitud, longitude: self.cleaners[i].longitud)
                if self.cleaners[i].ocupado {
                    newMarker.ocupado = true
                } else {
                    newMarker.ocupado = false
                }
                markers.append(newMarker)
                mapViewIOS.addAnnotation(newMarker)
            }
            i += 1
        }
        mapViewIOS.removeAnnotations(marcadoresACambiar)
        mapViewIOS.addAnnotations(marcadoresACambiar)
    }
    
    func removeMarkersAndUpdate() {
        var i = 0
        while markers.count > i {
            if cleaners.count > i {
                markers[i].coordinate = CLLocationCoordinate2D(latitude: self.cleaners[i].latitud, longitude: self.cleaners[i].longitud)
                if self.cleaners[i].ocupado {
                    markers[i].ocupado = true
                } else {
                    markers[i].ocupado = false
                }
            } else {
                self.mapViewIOS.removeAnnotation(markers[i])
                markers.remove(at: i)
            }
            i += 1
        }
        mapViewIOS.removeAnnotations(markers)
        mapViewIOS.addAnnotations(markers)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        if annotation is CustomCleanerMarker {
            let annot:CustomCleanerMarker = annotation as! MapController.CustomCleanerMarker
            var image:UIImage
            
            if  annot.ocupado{
                image = UIImage(named: "washer_bike_ocupado")!
            } else {
                image = UIImage(named: "washer_bike")!
            }
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: "washer")
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: "washer")
            }
            
            let si = CGSize(width: 32.0, height: 34.0)
            UIGraphicsBeginImageContext(si)
            image.draw(in: CGRect(x: 0, y: 0, width: 32.0, height: 34.0))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            anView?.image = newImage
            return anView
        } else if annotation is CustomCentralMarker {
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: "central")
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: "central")
            }
            let image = UIImage(named: "Location")
            anView?.image = image
            
            return anView
        }
        else {
            return MKAnnotationView()
        }
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
                        } else if pm.thoroughfare != nil && pm.subThoroughfare != nil && pm.subLocality != nil && pm.locality != nil {
                            self.locationText.text = "\(pm.thoroughfare!) \(pm.subThoroughfare!), \(pm.subLocality!), \(pm.locality!)"
                        } else if pm.thoroughfare != nil && pm.subThoroughfare != nil && pm.subLocality != nil {
                            self.locationText.text = "\(pm.thoroughfare!) \(pm.subThoroughfare!), \(pm.subLocality!)"
                        } else if pm.thoroughfare != nil && pm.subThoroughfare != nil {
                            self.locationText.text = "\(pm.thoroughfare!) \(pm.subThoroughfare!)"
                        } else if pm.thoroughfare != nil {
                            self.locationText.text = "\(pm.thoroughfare!)"
                        } else {
                            self.locationText.text = "No se puede leer la ubicacion"
                        }
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
        case OUTSIDE_OR_INSIDE_SELECTED:
            configureServiceTypeState()
            viewState = SERVICE_START
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
        locationText.isHidden = false
    }
    
    func configureVehicleSelectedState(){
        upLayoutHeight.constant = upLayoutSize
        lowLayoutHeight.constant = lowLayoutSize
        startLayoutHeight.constant = 0
        upLayout.isHidden = false
        lowLayout.isHidden = false
        startLayout.isHidden = true
        rightButton.isHidden = false
        rightDescriptionView.isHidden = false
        var leftTitle = "Lavado Exterior"
        var rightTitle = "Lavado Interior"
        leftDescriptionLeft.text = self.normalLeftText
        do {
            var precio = ""
        switch vehicleType {
        case String(Service.BIKE):
            precio = try buscarPrecioPorIdServicioYIdVehiculo(idServicio: 1, idVehiculo: Service.BIKE)
            leftTitle += " $\(precio)"
            rightButton.isHidden = true
            rightDescriptionView.isHidden = true
            leftDescriptionLeft.text = self.bikeLeftText
            break
        case String(Service.CAR):
            precio = try buscarPrecioPorIdServicioYIdVehiculo(idServicio: 1, idVehiculo: Service.CAR)
            leftTitle += " $\(precio)"
            precio = try buscarPrecioPorIdServicioYIdVehiculo(idServicio: 2, idVehiculo: Service.CAR)
            rightTitle += " $\(precio)"
            break
        case String(Service.SMALL_VAN):
            precio = try buscarPrecioPorIdServicioYIdVehiculo(idServicio: 1, idVehiculo: Service.SMALL_VAN)
            leftTitle += " $\(precio)"
            precio = try buscarPrecioPorIdServicioYIdVehiculo(idServicio: 2, idVehiculo: Service.SMALL_VAN)
            rightTitle += " $\(precio)"
            break
        case String(Service.BIG_VAN):
            precio = try buscarPrecioPorIdServicioYIdVehiculo(idServicio: 1, idVehiculo: Service.BIG_VAN)
            leftTitle += " $\(precio)"
            precio = try buscarPrecioPorIdServicioYIdVehiculo(idServicio: 2, idVehiculo: Service.BIG_VAN)
            rightTitle += " $\(precio)"
            break
        default:
            break
        }
        leftButton.setTitle(leftTitle, for: .normal)
        rightButton.setTitle(rightTitle, for: .normal)
        } catch {
            createAlertInfo(message: "No se encontro precio para este vehiculo")
            viewState = STANDBY
            configureState()
        }
    }
    
    func buscarPrecioPorIdServicioYIdVehiculo(idServicio:Int, idVehiculo:Int) throws -> String
    {
        for precio in precios {
            if precio.idServicio == idServicio && precio.idVehiculo == idVehiculo {
                return String(precio.precio)
            }
        }
        throw MapaError.errorBuscandoPrecio
    }
    
    
    func configureServiceTypeState(){
        if serviceRequestFlag {
            return
        }
        serviceRequestFlag = true
        let confirmAlert = UIAlertController(title: "", message: "Confirmar pedido del servicio", preferredStyle: UIAlertControllerStyle.alert)
        confirmAlert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default, handler: {action in
            self.serviceRequestFlag = false
        }))
        confirmAlert.addAction(UIAlertAction(title: "Confirmar", style: UIAlertActionStyle.default, handler: {action in
            DispatchQueue.global(qos: .background).async {
                self.sendRequestService()
            }
        }))
        self.present(confirmAlert, animated: true, completion: nil)
    }
    
    func configureServiceStartState(){
        upLayoutHeight.constant = 0
        lowLayoutHeight.constant = 0
        startLayoutHeight.constant = startLayoutSize
        upLayout.isHidden = true
        lowLayout.isHidden = true
        startLayout.isHidden = false
        cancelButton.isHidden = false
        serviceInfo.text = "BUSCANDO LAVADOR"
        locationText.isHidden = true
        configureActiveServiceView()
    }
    
    func sendRequestService(){
        do{
            let favCar = DataBase.getFavoriteCar()!
            AppData.deleteMessage()
            let serviceRequested = try Service.requestService(direccion: self.locationText.text!, withLatitud: String(requestLocation.coordinate.latitude), withLongitud: String(requestLocation.coordinate.longitude), withId: service, withToken: token, withCar: vehicleType, withFavoriteCar: favCar.id, conMetodoDePago: metodoDePago, conIdDeRegion: idRegion)
            cancelCode = 0;
            activeService = serviceRequested
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.stateReceived = 0
            DispatchQueue.main.async {
                self.upLayoutHeight.constant = 0
                self.lowLayoutHeight.constant = 0
                self.startLayoutHeight.constant = self.startLayoutSize
                self.upLayout.isHidden = true
                self.lowLayout.isHidden = true
                self.startLayout.isHidden = false
                self.cancelButton.isHidden = false
                self.cleanerInfo.isHidden = true
                self.locationText.isHidden = true
                self.serviceInfo.text = "Buscando Lavador"
            }
            startActiveServiceCycle()
            cancelSent = false
        } catch Service.ServiceError.noSessionFound{
            ProfileReader.delete()
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
            DispatchQueue.main.async {
                self.navigationController?.setViewControllers([nextViewController], animated: true)
                _ = self.navigationController?.popToRootViewController(animated: true)
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
        if !running {
            activeServiceCycleThread.async {
                self.running = true
                self.activeServiceCycle()
                self.running = false
            }
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
            var diffInMillis = activeService.acceptedTime.addingTimeInterval(60 * 5).timeIntervalSinceNow
            if diffInMillis < 0 {
                diffInMillis = 0
            } else {
                DispatchQueue.main.async {
                    self.cancelButton.isHidden = false
                }
            }
            cancelCode = 1
            let t = DispatchTime.now() + diffInMillis
            DispatchQueue.main.asyncAfter(deadline: t, execute: {
                self.cancelButton.isHidden = true
            });
            configureActiveService(display: "Llegando en: 15 min")
            
            let cancelAlarmClockQueue = DispatchQueue(label: "com.alan.clockCancel", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
            self.cancelAlarmClock = DispatchSource.makeTimerSource(flags: .strict, queue: cancelAlarmClockQueue)
            self.cancelAlarmClock.scheduleRepeating(deadline: .now() + .seconds(60*15), interval: .seconds(60*15), leeway: .seconds(60))
            self.cancelAlarmClock.setEventHandler(handler: {
                DispatchQueue.main.async {
                    self.alertForCancel()
                }
            })
            self.cancelAlarmClock.resume()
            break
        case "On The Way":
            if self.cancelAlarmClock != nil {
                self.cancelAlarmClock.cancel()
            }
            configureActiveService(display: "De camino")
            break
        case "Started":
            DispatchQueue.main.async {
                self.cancelButton.isHidden = true
            }
            if self.cancelAlarmClock != nil {
                self.cancelAlarmClock.cancel()
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
        self.checkNotification()
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
        if let message = AppData.getMessage() {
            if message != "Finished" {
                DispatchQueue.main.async {
                    self.createAlertInfo(message: message)
                }
            }
            AppData.deleteMessage()
        }
    }
    
    func configureActiveServiceForLooking(){
        DispatchQueue.main.async {
            self.cleanerInfo.isHidden = true
            self.cleanerImageInfo.isHidden = true
            self.serviceInfo.text = "Buscando lavador"
            self.cancelButton.isHidden = false
            if self.activeService != nil{
                self.centralMarker.coordinate = CLLocationCoordinate2D(latitude: self.activeService.latitud, longitude: self.activeService.longitud)
                self.mapViewIOS.addAnnotation(self.centralMarker)
            }
            for marker in self.markers {
                self.mapViewIOS.removeAnnotation(marker)
            }
        }
    }
    
    func configureActiveServiceForFinished(){
        //TODO: check for optimization
        if clock != nil {
            clock.cancel()
        }
        if activeService.rating == -1 {
            cancelTimers()
            if !AppData.isSummaryOpened() {
                DispatchQueue.main.async {
                    if self.alert != nil {
                        self.alert.dismiss(animated: true, completion: nil)
                    }
                    let storyBoard = UIStoryboard(name: "Map", bundle: nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "summary") as! SummaryController
                    self.navigationController?.pushViewController(nextViewController, animated: true)
                }
            }
        }
        serviceRequestFlag = false
    }
    
    func modifyClock(){
        if activeService != nil {
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
                self.centralMarker.coordinate = CLLocationCoordinate2D(latitude: self.activeService.latitud, longitude: self.activeService.longitud)
            }
        }
        setImageDrawableForActiveService()
    }
    
    func setImageDrawableForActiveService(){
        let url = URL(string: "http://54.218.50.2/api/1.0.0/images/cleaners/" + activeService.cleanerId + "/profile_image.jpg")
        do {
            let data:Data = try Data(contentsOf: url!)
            self.cleanerImageInfo.image = UIImage(data: data)
        } catch {
            self.cleanerImageInfo.image = UIImage(named: "default_image")
        }
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
        self.cancelAlarmClock.suspend()
        var cancelAlert:UIAlertController!
        if cancelCode == 2 {
            cancelAlert = UIAlertController(title: "Lavador esta tomando mucho tiempo", message: "Deseas cancelar?", preferredStyle: UIAlertControllerStyle.alert)
            cancelAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                self.sendCancel()
            }))
            cancelAlert.addAction(UIAlertAction(title: "Esperar", style: UIAlertActionStyle.default, handler: { action in
                self.cancelAlarmClock.resume()
            }))
        } else {
            cancelAlert = UIAlertController(title: "Cancelar", message: "Cancelar en este momento incluye un costo extra, estas seguro...?", preferredStyle: UIAlertControllerStyle.alert)
            cancelAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                self.sendCancel()
                if self.cancelAlarmClock != nil {
                    self.cancelAlarmClock.cancel()
                }
            }))
            cancelAlert.addAction(UIAlertAction(title: "Esperar", style: UIAlertActionStyle.default, handler: nil))
        }
        self.present(cancelAlert, animated: true, completion: nil)
    }
    
    @IBAction func clickCancel(_ sender: AnyObject) {
        if cancelCode == 0 && !cancelSent{
            sendCancel()
        } else if cancelCode == 1 {
            buildAlertForCancel()
        }
    }
    
    func sendCancel(){
        cancelSent = true
        DispatchQueue.global().async {
            do {
                if self.activeService == nil {
                    return
                }
                try Service.cancelService(idService: self.activeService.id,withToken: self.token,withTimeOutCancel: self.cancelCode)
                if self.cancelAlarmClock != nil {
                    self.cancelAlarmClock.cancel()
                }
            } catch Service.ServiceError.noSessionFound{
                ProfileReader.delete()
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "main")
                DispatchQueue.main.async {
                    self.present(nextViewController, animated: true, completion: nil)
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }
            } catch {
                self.createAlertInfo(message: "Error al cancelar")
                self.cancelSent = false
                if self.cancelAlarmClock != nil {
                    self.cancelAlarmClock.resume()
                }
            }
        }
    }
    
    
    @IBAction func leftClick(_ sender: AnyObject) {
        service = String(Service.OUTSIDE)
        viewState = OUTSIDE_OR_INSIDE_SELECTED
        configureState()
    }
    
    @IBAction func rightClick(_ sender: AnyObject) {
        service = String(Service.OUTSIDE_INSIDE)
        viewState = OUTSIDE_OR_INSIDE_SELECTED
        configureState()
    }
    
    @IBAction func vehicleClicked(_ sender: UIButton) {
        let latitud = requestLocation.coordinate.latitude
        let longitud = requestLocation.coordinate.longitude
        //TODO: preexecute
        DispatchQueue.global(qos: .background).async {
            self.buscarPreciosAsync(latitud: latitud, longitud: longitud)
        }
    }
    
    
    func initLocation(){
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
    }
    
    func initView(){
        menuOpenButton.target = self.revealViewController()
        menuOpenButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        let slide: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.stateBack))
        slide.direction = UISwipeGestureRecognizerDirection.down
        self.lowLayout.addGestureRecognizer(slide)
        self.upLayout.addGestureRecognizer(slide)
        self.locationText.delegate = self
        self.revealViewController().delegate = self
        if creditCard == nil {
            metodoDePago = "e"
            metodoDePagoTexto.setTitle("Efectivo", for: .normal)
        } else {
            metodoDePago = "t"
            metodoDePagoTexto.setTitle("Tarjeta", for: .normal)
        }
    }
    
    func stateBack(){
        self.viewState = self.STANDBY
        self.configureState()
    }
    
    func initMap(){
        self.mapViewIOS.showsUserLocation = true
        self.mapViewIOS.userTrackingMode = .follow
        let span = MKCoordinateSpanMake(0.02, 0.02)
        var location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.mapViewIOS.delegate = self
        
        if self.userLocation != nil {
            location = CLLocationCoordinate2D(latitude: self.userLocation.coordinate.latitude, longitude: self.userLocation.coordinate.longitude)
            
        } else if self.mapViewIOS.userLocation.location != nil{
            location = CLLocationCoordinate2D(latitude: (self.mapViewIOS.userLocation.location?.coordinate.latitude)!, longitude: (self.mapViewIOS.userLocation.location?.coordinate.longitude)!)
        }
        let region = MKCoordinateRegionMake(location, span)
        mapViewIOS.setRegion(region, animated: true)
        self.centralMarker.coordinate = location
        self.requestLocation = CLLocation(latitude: self.centralMarker.coordinate.latitude, longitude: self.centralMarker.coordinate.longitude)
        mapViewIOS.addAnnotation(centralMarker)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapMap))
        self.mapViewIOS.addGestureRecognizer(tap)
        
        let mapDragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.dragMap))
        mapDragRecognizer.delegate = self
        self.mapViewIOS.addGestureRecognizer(mapDragRecognizer)
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.view.endEditing(true)
        let position = mapViewIOS.region.center
        if activeService == nil {
            self.locationText.text = "BUSCANDO..."
            centralMarker.coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
            requestLocation = CLLocation(latitude: position.latitude, longitude: position.longitude)
            if let tempLocation = self.requestLocation {
                geoLocationQueue.asyncAfter(deadline: .now() + 3, execute: {
                    self.reloadAddress(location: tempLocation)
                })
            }
        }
    }
    
    func dragMap(gestureRecognizer: UIGestureRecognizer){
        self.view.endEditing(true)
        let position = mapViewIOS.region.center
        if activeService == nil {
            centralMarker.coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
            self.mapViewIOS.addAnnotation(centralMarker)
            self.locationText.text = ""
        }
    }
    
    func tapMap(){
        self.view.endEditing(true)
        if menuOpen {
            self.revealViewController().revealToggle(animated: true)
        }
        if activeService == nil {
            self.stateBack()
        }
    }
    
    @IBAction func myLocationClicked(_ sender: AnyObject) {
        var location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        if self.userLocation != nil {
            location = CLLocationCoordinate2D(latitude: self.userLocation.coordinate.latitude, longitude: self.userLocation.coordinate.longitude)
        }
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(location, span)
        self.mapViewIOS.setRegion(region, animated: true)
    }
    
    func createAlertInfo(message:String){
        print(message)
        //TODO: dismiss alert?
        if self.alert != nil {
            self.alert.dismiss(animated: true, completion: nil)
        }
        self.alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        self.alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {action in
            self.clickedAlertOK = true
        }))
        self.present(self.alert, animated: true, completion: nil)
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
                let span = MKCoordinateSpanMake(0.02, 0.02)
                let location = CLLocationCoordinate2D(latitude: (placemark.location?.coordinate.latitude)!, longitude: (placemark.location?.coordinate.longitude)!)
                let region = MKCoordinateRegionMake(location, span)
                self.mapViewIOS.setRegion(region, animated: true)
            }
        })
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @IBAction func mostrarCambioMetodoDePago(_ sender: Any) {
        if creditCard != nil {
            let alerta = UIAlertController(title: "?Que metodo de pago deseas utilizar?", message: "Si seleccionas efectivo deberas estar presente cuando llegue el lavador para pagar antes de iniciar el servicio", preferredStyle: UIAlertControllerStyle.actionSheet)
            alerta.addAction(UIAlertAction(title: "Efectivo", style: UIAlertActionStyle.default, handler: { action in
                self.metodoDePago = "e"
                self.metodoDePagoTexto.setTitle("Efectivo", for: .normal)
            }))
            alerta.addAction(UIAlertAction(title: "Tarjeta", style: UIAlertActionStyle.default, handler: { action in
                self.metodoDePago = "t"
                self.metodoDePagoTexto.setTitle("Tarjeta", for: .normal)
            }))
            self.present(alerta, animated: true, completion: nil)
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        if(position == .left) {
            menuOpen = false
        } else {
            menuOpen = true
        }
    }
    
    class CustomCentralMarker: MKPointAnnotation {
        let image = UIImage(named: "default_marker")
    }
    class CustomCleanerMarker: MKPointAnnotation {
        var ocupado = false
    }
    
    func buscarPreciosAsync(latitud:Double, longitud:Double)
    {
        do {
            precios = try Service.leerPrecios(latitud: latitud, longitud: longitud)
            if precios.count > 0 {
                idRegion = precios[0].region
                DispatchQueue.main.async {
                    self.buscarPreciosPostExec()
                }
            } else {
                createAlertInfo(message: "Error al leer los precios")
            }
            
        } catch {
            createAlertInfo(message: "Error al leer los precios")
        }
    }
    
    func buscarPreciosPostExec()
    {
        if viewState != STANDBY {
            return
        }
        if cleaners.count < 1 {
            createAlertInfo(message: "No hay lavadores cercanos")
            DispatchQueue.global(qos: .background).async {
                Reportes.sendReport(descripcion: "Demanda", latitud: self.requestLocation.coordinate.latitude, longitud: self.requestLocation.coordinate.longitude)
            }
            return
        }
        viewState = VEHICLE_SELECTED
        vehicleType = DataBase.getFavoriteCar()?.type
        configureState()
    }
    
    public enum MapaError:Error {
        case errorBuscandoPrecio
    }
}
