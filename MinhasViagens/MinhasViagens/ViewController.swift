//
//  ViewController.swift
//  MinhasViagens
//
//  Created by Jefferson Oliveira de Araujo on 13/11/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    var managerLocation = CLLocationManager()
    var trip: Dictionary<String, String> = [:]
    var indexSelected: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let index = indexSelected {
            if index == -1 { // Adicionando
                configManagerLocation()
            } else { // Listando
                displayAnnotation(trip: trip)
            }
        }
        
//        MARK: DEFININDO O TEMPO DE CLIQUE NA TELA E MARCANDO LOCAL
        let pressLocation = UILongPressGestureRecognizer(target: self, action: #selector( ViewController.markLocation(gesture:) ))
        pressLocation.minimumPressDuration = 1.5
        
        map.addGestureRecognizer(pressLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationLast = locations.last!
        
        //                            MARK: EXIBIR LOCAL
        let location = CLLocationCoordinate2D(latitude: locationLast.coordinate.latitude, longitude: locationLast.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
    }
    
    func displayLocation(latitude: Double, longitude: Double) {
        //                            MARK: EXIBIR LOCAL
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
    }
    
    func displayAnnotation(trip: Dictionary<String, String>) {
        //            MARK: EXIBINDO ANOTA????O COM OS DADOS DE ENDERE??O
        if let localTrip = trip["Local"] {
            if let latitudeS = trip["Latitude"] {
                if let longitudeS = trip["Longitude"] {
                    if let latitude = Double(latitudeS) {
                        if let longitude = Double(longitudeS) {
                            
                            //                            MARK: ADICIONAR MARCA????O
                            let  annotation = MKPointAnnotation()
                            annotation.coordinate.latitude = latitude
                            annotation.coordinate.longitude = longitude
                            annotation.title = localTrip
                            //     annotation.subtitle = "Estou exatamente aqui"
                            self.map.addAnnotation(annotation)
                            
                            displayLocation(latitude: latitude, longitude: longitude)
                        }
                    }
                }
            }
        }
    }
    
    @objc func markLocation(gesture: UIGestureRecognizer) {
        
//        MARK: GARANTINDO QUE SER?? MARCADO APENAS UM GESTO POR DURA????O
        if gesture.state == UIGestureRecognizer.State.began {
            
//            MARK: RECUPERANDO AS COORDENADAS DO PONTO SELECIONADO
            let pointSelect = gesture.location(in: self.map)
            let coordinate = map.convert(pointSelect, toCoordinateFrom: self.map)
            let locationConvert = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
//            MARK: RECUPERAR ENDERE??O DE UM PONTO SELECIONADO
            var completeLocal = "Endere??o n??o encontrado!"
            CLGeocoder().reverseGeocodeLocation(locationConvert) { (local, error) in
                if error == nil {
                    if let dataLocal = local?.first {
                        if let name = dataLocal.name {
                            completeLocal = name
                        } else {
                            if let address = dataLocal.thoroughfare {
                                completeLocal = address
                            }
                        }
                    }
                    
//            MARK: SALVAR DADOS NO DISPOSITIVO
                    self.trip = ["Local": completeLocal, "Latitude": String(coordinate.latitude), "Longitude": String(coordinate.longitude)]
                    DataStorage().saveTrips(trip: self.trip)
                    
//            MARK: EXIBINDO ANOTA????O COM OS DADOS DE ENDERE??O
                    self.displayAnnotation(trip: self.trip)
                } else {
                    print(error)
                }
            }
        }
    }
    
//    MARK: CONFIGURA????O PARA SOLICITAR PERMISS??O DO USU??RIO PARA O GPS
    func configManagerLocation() {
        managerLocation.delegate = self
        managerLocation.desiredAccuracy = kCLLocationAccuracyBest
        managerLocation.requestWhenInUseAuthorization()
        managerLocation.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse {
            let alertController = UIAlertController(title: "Permiss??o de autoriza????o", message: "Necess??rio permiss??o para acesso ?? sua localiza????o", preferredStyle: .alert)
            
//            MARK: ABRINDO AS CONFIGURA????ES DO CELULAR PARA DAR PERMISS??O AO APP
            let actionConfig = UIAlertAction(title: "Abrir configura????es", style: .default) { (alertConfig) in
                if let config = NSURL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open( config as URL)
                }
            }
            
            let actionCancel = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            
            alertController.addAction(actionConfig)
            alertController.addAction(actionCancel)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}
