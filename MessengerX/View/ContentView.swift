//
//  ContentView.swift
//  MessengerX
//
//  Created by Osama on 05/10/2020.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    
    var body: some View {
        VStack {
            if status {
                NavigationView {
                    Home().environmentObject(MainObservable())
                }
            }
            else {
                NavigationView {
                    FirstPage()
                }
            }
        }.onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChanged"), object: nil, queue: .main) {
                (_) in
                let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                self.status = status
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


class MainObservable : ObservableObject {
    
    @Published var recents      = [Recent]()
    @Published var noRecents    = false
    
    init() {
        let db  = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        
        db.collection("users").document(uid!).collection("recents").order(by: "date", descending: true).addSnapshotListener {
            (snap, err) in
            
            if err != nil {
                print(err?.localizedDescription ?? "")
                self.noRecents = true
                return
            }
            
            if snap!.isEmpty {
                self.noRecents = true
            }
            
            for i in snap!.documentChanges {
                
                if i.type == .added {
                    let id = i.document.documentID
                    let name = i.document.get("name") as! String
                    let pic = i.document.get("pic") as! String
                    let lastMsg = i.document.get("lastmsg") as! String
                    let stamp = i.document.get("date") as! Timestamp
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yy"
                    let date = formatter.string(from: stamp.dateValue())
                    
                    formatter.dateFormat = "hh:mm a"
                    let time = formatter.string(from: stamp.dateValue())
                    
                    self.recents.append(Recent(id: id, name: name, pic: pic, lastMsg: lastMsg, time: time, date: date, stamp: stamp.dateValue()))
                }
            
                if i.type == .modified {
                    let id = i.document.documentID
                    let lastMsg = i.document.get("lastmsg") as! String
                    let stamp = i.document.get("date") as! Timestamp
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yy"
                    let date = formatter.string(from: stamp.dateValue())
                    
                    formatter.dateFormat = "hh:mm a"
                    let time = formatter.string(from: stamp.dateValue())
                    
                    for j in 0..<self.recents.count {
                        if self.recents[j].id == id {
                            self.recents[j].lastMsg  = lastMsg
                            self.recents[j].time     = time
                            self.recents[j].date     = date
                            self.recents[j].stamp    = stamp.dateValue()
                        }
                    }
                    
                }
            }
        }
    }
}

struct Recent: Identifiable {
    var id: String
    var name: String
    var pic: String
    var lastMsg: String
    var time: String
    var date: String
    var stamp: Date
}
