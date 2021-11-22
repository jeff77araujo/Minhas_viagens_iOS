//
//  DataStorage.swift
//  MinhasViagens
//
//  Created by Jefferson Oliveira de Araujo on 15/11/21.
//

import UIKit


class DataStorage {
    
    let keyStorage = "Locais salvos"
    var trips: [Dictionary<String, String>] = []
    
    func getDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    func saveTrips(trip: Dictionary<String, String>) {
        trips = listTrips()
        trips.append(trip)
        
        saveAndSynchonize()
    }
    
    func listTrips() -> [Dictionary<String, String>] {
        let data = getDefaults().object(forKey: keyStorage)
        print(data)
        if data != nil {
            return data as! [Dictionary<String, String>]
        } else {
            return []
        }
    }
    
    func deleteTrips(index: Int) {
        trips = listTrips()
        trips.remove(at: index)
        
        saveAndSynchonize()
    }
    
    func saveAndSynchonize() {
        getDefaults().set(trips, forKey: keyStorage)
        getDefaults().synchronize()
    }
}
