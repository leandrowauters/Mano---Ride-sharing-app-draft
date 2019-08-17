//
//  AuthService.swift
//  Mano
//
//  Created by Leandro Wauters on 7/17/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

protocol AuthServiceCreateNewAccountDelegate: AnyObject {
    func didRecieveErrorCreatingAccount(_ authservice: AuthService, error: Error)
    func didCreateNewAccount(_ authservice: AuthService, user: ManoUser)
}

protocol AuthServiceExistingAccountDelegate: AnyObject {
    func didRecieveErrorSigningToExistingAccount(_ authservice: AuthService, error: Error)
    func didSignInToExistingAccount(_ authservice: AuthService, user: User)
}

protocol AuthServiceSignOutDelegate: AnyObject {
    func didSignOutWithError(_ authservice: AuthService, error: Error)
    func didSignOut(_ authservice: AuthService)
}

protocol AuthServiceSignInWithGoogleAccount: AnyObject {
    
}

enum TypeOfUser: String {
    case Passenger, Driver
}

final class AuthService {
    weak var authserviceCreateNewAccountDelegate: AuthServiceCreateNewAccountDelegate?
    weak var authserviceExistingAccountDelegate: AuthServiceExistingAccountDelegate?
    weak var authserviceSignOutDelegate: AuthServiceSignOutDelegate?
     
    
    public func createAccount(firstName: String, lastName: String, password: String, email: String, typeOfUser: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error {
                self.authserviceCreateNewAccountDelegate?.didRecieveErrorCreatingAccount(self, error: error)
                return
            }
            else if let authDataResult = authDataResult {
                 let joinedDate = Date.getISOTimestamp()
                let manoUser = ManoUser(firstName: firstName, lastName: lastName, fullName: ((firstName ) + " " + (lastName )).trimmingCharacters(in: .whitespacesAndNewlines), homeAdress: nil, homeLat: nil, homeLon: nil, profileImage: nil, carMakerModel: nil, bio: nil, typeOfUser: typeOfUser, patients: nil, joinedDate: joinedDate, userId: authDataResult.user.uid, numberOfRides: nil, numberOfMiles:  nil, licencePlate: nil, carPicture: nil, cellPhone: nil)
                DBService.createUser(manoUser: manoUser, completion: { (error) in
                    if let error = error {
                        self.authserviceCreateNewAccountDelegate?.didRecieveErrorCreatingAccount(self, error: error)
                    }
                    self.authserviceCreateNewAccountDelegate?.didCreateNewAccount(self, user: manoUser)
                })
            }
        }
        
    }
    
    public func googleUserCreateAccount(manoUser: ManoUser) {
        DBService.createUser(manoUser: manoUser, completion: { (error) in
            if let error = error {
                self.authserviceCreateNewAccountDelegate?.didRecieveErrorCreatingAccount(self, error: error)
            }
            self.authserviceCreateNewAccountDelegate?.didCreateNewAccount(self, user: manoUser)
        })
    }


    public func signInExistingAccount(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error {
                self.authserviceExistingAccountDelegate?.didRecieveErrorSigningToExistingAccount(self, error: error)
            } else if let authDataResult = authDataResult {
                self.authserviceExistingAccountDelegate?.didSignInToExistingAccount(self, user: authDataResult.user)
            }
        }
    }
    

    public func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    public func signOutAccount() {
        do {
            try Auth.auth().signOut()
            authserviceSignOutDelegate?.didSignOut(self)
        } catch {
            authserviceSignOutDelegate?.didSignOutWithError(self, error: error)
        }
    }
    
    public func deleteAccount(completion: @escaping(Error?) -> Void) {
        Auth.auth().currentUser?.delete(completion: { (error) in
            if let error = error {
                completion(error)
            }
            DBService.deleteAccount(user: DBService.currentManoUser, completion: { (error) in
                if let error = error {
                    completion(error)
                }
                completion(nil)
            })
        })
    }
}
