//
//  DataPersistanceModel.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation

struct DataPersistanceModel {
    
    private static var manoUsers = [ManoUser]()
    private static let saveLocationFileName = "SavedManoUser.plist"
    
    static func getManoUser() -> [ManoUser]{
        let path = DataPersistanceManager.filepathToDocumentsDirectory(filename: saveLocationFileName).path
        if FileManager.default.fileExists(atPath: path) {
            if let data = FileManager.default.contents(atPath: path){
                do {
                    manoUsers = try PropertyListDecoder().decode([ManoUser].self, from: data)
                }catch {
                    print ("property list dedoding error:\(error)")
                }
            }
        } else {
            print("\(saveLocationFileName) does not exist")
        }
        return manoUsers
    }
    
    static func addManoUser(manoUser: ManoUser){
        manoUsers.append(manoUser)
        saveManoUser()
    }
    
    static func deleteGame(manoUser: ManoUser, atIndex index: Int){
        manoUsers.remove(at: index)
        saveManoUser()
    }
    static func saveManoUser(){
        let path = DataPersistanceManager.filepathToDocumentsDirectory(filename: saveLocationFileName)
        do{
            let data = try PropertyListEncoder().encode(manoUsers)
            try data.write(to: path, options:  .atomic)
        }catch{
            print("Property list encoding error \(error)")
        }
    }
}
