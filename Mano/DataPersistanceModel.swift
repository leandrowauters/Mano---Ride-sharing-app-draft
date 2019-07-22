//
//  DataPersistanceModel.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation

struct DataPersistanceModel {
    
    private static var myLocations = [MyLocation]()
    private static let saveLocationFileName = "SavedGames.plist"
    
    static func getMyLocations() -> [MyLocation]{
        let path = DataPersistanceManager.filepathToDocumentsDirectory(filename: saveLocationFileName).path
        if FileManager.default.fileExists(atPath: path) {
            if let data = FileManager.default.contents(atPath: path){
                do {
                    myLocations = try PropertyListDecoder().decode([MyLocation].self, from: data)
                }catch {
                    print ("property list dedoding error:\(error)")
                }
            }
        } else {
            print("\(saveLocationFileName) does not exist")
        }
        return myLocations
    }
    
    static func addMyLocation(myLocation: MyLocation){
        myLocations.append(myLocation)
        saveMyLocation()
    }
    
    static func deleteGame(myLocation: MyLocation, atIndex index: Int){
        myLocations.remove(at: index)
        saveMyLocation()
    }
    static func saveMyLocation(){
        let path = DataPersistanceManager.filepathToDocumentsDirectory(filename: saveLocationFileName)
        do{
            let data = try PropertyListEncoder().encode(myLocations)
            try data.write(to: path, options:  .atomic)
        }catch{
            print("Property list encoding error \(error)")
        }
    }
}
