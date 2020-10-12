//
//  CheckUser.swift
//  MessengerX
//
//  Created by Osama on 07/10/2020.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

func checkUser(completion: @escaping (Bool, String, String, String) -> Void) {
    let db = Firestore.firestore()
    db.collection("users").getDocuments { (snap, err) in
        if err != nil {
            print(err?.localizedDescription ?? "Error!")
            return
        }
        
        for i in snap!.documents {
            if i.documentID == Auth.auth().currentUser?.uid {
                completion(true, i.get("name") as! String, i.get("uid") as! String, i.get("pic") as! String)
                return
            }
        }
        
        completion(false, "", "", "")
    }
}


