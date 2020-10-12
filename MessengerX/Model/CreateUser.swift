//
//  CreateUser.swift
//  MessengerX
//
//  Created by Osama on 07/10/2020.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


func createUser(for name: String, and about: String, with imageData: Data, completion: @escaping (Bool) -> Void) {
    let db      = Firestore.firestore()
    let storage = Storage.storage().reference()
    let uid     = Auth.auth().currentUser?.uid
    
    storage.child("profilepics").child(uid!).putData(imageData, metadata: nil) { ( _, err) in
        if err != nil {
            print(err?.localizedDescription ?? "")
            completion(false)
            return
        }
        
        storage.child("profilepics").child(uid!).downloadURL { (url, err) in
            if err != nil {
                print(err?.localizedDescription ?? "")
                completion(false)
                return
            }
            
            db.collection("users").document(uid!).setData(["name": name, "about": about, "pic": "\(url!)", "uid": uid!]) { (err) in
                if err != nil {
                    print(err?.localizedDescription ?? "")
                    completion(false)
                    return
                }
                
                completion(true)
                UserDefaults.standard.set(true, forKey: "status")
                UserDefaults.standard.set(name, forKey: "username")
                UserDefaults.standard.set(url!, forKey: "pic")
                UserDefaults.standard.set(uid, forKey: "UID")
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "statusChanged"), object: nil)
            }
        }
    }
}
