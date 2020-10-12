//
//  Home.swift
//  MessengerX
//
//  Created by Osama on 07/10/2020.
//

import SwiftUI
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI

struct Home: View {
    
    @State var myUID    = UserDefaults.standard.value(forKey: "username") as! String
    @EnvironmentObject var datas: MainObservable
    @State var show     = false
    @State var chat     = false
    @State var uid      = ""
    @State var name     = ""
    @State var pic      = ""
    
    var body: some View {
        
        ZStack {
            NavigationLink(destination: ChatView(uid: self.uid, name: self.name, pic: self.pic, chat: self.$chat), isActive: self.$chat) {
                Text("")
            }
            VStack {
                if self.datas.recents.count == 0 {
                    
                    if self.datas.noRecents {
                        Text("No Chat History").foregroundColor(.black).opacity(0.5)
                    }
                    else {
                        Indicator()
                    }
                }
                else {
                    ScrollView( .vertical, showsIndicators: false) {
                        VStack(spacing: 12){
                            ForEach(datas.recents.sorted(by: {$0.stamp > $1.stamp})) { i in
                                Button {
                                    self.uid    = i.id
                                    self.name   = i.name
                                    self.pic    = i.pic
                                    self.chat.toggle()
                                } label: {
                                    RecentCellView(url: i.pic, name: i.name, time: i.time, date: i.date, lastMsg: i.lastMsg)
                                }
                            }
                        }.padding()
                    }
                }
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                                        
                                        UserDefaults.standard.set("", forKey: "username")
                                        UserDefaults.standard.set("", forKey: "UID")
                                        UserDefaults.standard.set("", forKey: "username")
                                        
                                        try! Auth.auth().signOut()
                                        
                                        UserDefaults.standard.set(false, forKey: "status")
                                        NotificationCenter.default.post(name: Notification.Name("statusChanged"), object: nil)
                                        
                                    }, label: {
                                        Text("Sign Out")
                                    })
                                , trailing:
                                    Button(action: {
                                        self.show.toggle()
                                    }, label: {
                                        Image(systemName: "square.and.pencil").resizable().frame(width: 25, height: 25)
                                    })
            )
        }
        .sheet(isPresented: self.$show) {
            newChatView(uid: self.$uid, name: self.$name, pic: self.$pic, chat: self.$chat, show: self.$show)
        }
    }
}

struct RecentCellView: View {
    var url: String
    var name: String
    var time: String
    var date: String
    var lastMsg: String
    
    
    var body: some View {
        HStack{
            AnimatedImage(url: URL(string: url)!).resizable().renderingMode(.original).frame(width: 55, height: 55).clipShape(Circle())
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(name).foregroundColor(.black)
                        Text(lastMsg).foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 6) {
                        Text(date).foregroundColor(.gray)
                        Text(time).foregroundColor(.gray)
                    }
                }
                Divider()
            }
        }
    }
}


struct newChatView: View {
    
    @ObservedObject var datas = getAllUsers()
    
    @Binding var uid: String
    @Binding var name: String
    @Binding var pic: String
    @Binding var chat: Bool
    @Binding var show: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            
            if self.datas.users.count == 0 {
                Indicator()
            }
            else {
                Text("Select to Chat").font(.title).foregroundColor(Color.black.opacity(0.5))
                
                ScrollView( .vertical, showsIndicators: false) {
                    VStack(spacing: 12){
                        ForEach(self.datas.users) { i in
                            Button {
                                self.uid    = i.id
                                self.name   = i.name
                                self.pic    = i.pic
                                self.show.toggle()
                                self.chat.toggle()
                            } label: {
                                UserCellView(url: i.pic, name: i.name, about: i.about)
                            }
                        }
                    }.padding()
                }
            }
            
        }.padding()
    }
}

class getAllUsers: ObservableObject {
    @Published var users = [User]()
    
    init() {
        let db = Firestore.firestore()
        
        db.collection("users").getDocuments { (snap, err) in
            if err != nil {
                print(err?.localizedDescription ?? "")
                return
            }
            
            for i in snap!.documents {
                let id      = i.documentID
                let name    = i.get("name") as! String
                let pic     = i.get("pic") as! String
                let about   = i.get("about") as! String
                
                if id != UserDefaults.standard.value(forKey: "UID") as! String {
                    self.users.append(User(id: id, name: name, pic: pic, about: about))
                }
            }
        }
    }
}

struct User: Identifiable {
    var id : String
    var name: String
    var pic: String
    var about: String
}

struct UserCellView: View {
    var url: String
    var name: String
    var about: String
    
    var body: some View {
        HStack{
            AnimatedImage(url: URL(string: url)!).resizable().renderingMode(.original).frame(width: 55, height: 55).clipShape(Circle())
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(name).foregroundColor(.black)
                        Text(about).foregroundColor(.gray)
                    }
                    Spacer()
                }
                Divider()
            }
        }
    }
}

struct ChatView: View {
    
    var uid: String
    var name: String
    var pic: String
    @Binding var chat: Bool
    @State var msgs = [Msg]()
    @State var txt  = ""
    @State var noMsgs = false
    
    var body: some View {
        
        VStack {
            
            if self.msgs.count == 0 {
                
                if self.noMsgs {
                    Text("Start a new conversation!").foregroundColor(.black).opacity(0.5)
                    Spacer()
                }
                else {
                    Spacer()
                    Indicator()
                    Spacer()
                }
            }
            else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(self.msgs) { i in
                            HStack {
                                if i.user == UserDefaults.standard.value(forKey: "UID") as! String {
                                    Spacer()
                                    Text(i.msg).padding().background(Color.blue).clipShape(ChatBubble(myMsg: true)).foregroundColor(.white)
                                }
                                else {
                                    Text(i.msg).padding().background(Color.green).clipShape(ChatBubble(myMsg: false)).foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            
            HStack {
                TextField("Enter Message", text: self.$txt).textFieldStyle(RoundedBorderTextFieldStyle())
                Button {
                    sendMsg(user: self.name, uid: self.uid, pic: self.pic, date: Date(), msg: self.txt)
                    self.txt = ""
                } label: {
                    Text("Send")
                }

            }
            .navigationBarTitle("\(self.name)", displayMode: .inline)
        }
        .padding()
        .onAppear {
            self.getMsgs()
        }
    }
    
    func getMsgs() {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        
        db.collection("msgs").document(uid!).collection(self.uid).order(by: "date", descending: false).addSnapshotListener { (snap, err) in
            if err != nil {
                print(err?.localizedDescription ?? "")
                self.noMsgs = true
                return
            }
            
            if snap!.isEmpty {
                self.noMsgs = true
            }
            
            for i in snap!.documentChanges {
                if i.type == .added {
                    let id = i.document.documentID
                    let msg = i.document.get("msg") as! String
                    let user = i.document.get("user") as! String
                    
                    self.msgs.append(Msg(id: id, msg: msg, user: user))
                }
            }
        }
    }
}

struct Msg: Identifiable {
    
    var id: String
    var msg: String
    var user: String
}

struct ChatBubble: Shape {
    var myMsg: Bool
    
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight, myMsg ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 16, height: 16))
        return Path(path.cgPath)
    }
}

func sendMsg(user: String, uid: String, pic: String, date: Date, msg: String) {
    
    let db = Firestore.firestore()
    let myUid = Auth.auth().currentUser?.uid
    
    db.collection("user").document(uid).collection("recents").document(myUid!).getDocument { (snap, err) in
        if err != nil {
            print(err?.localizedDescription ?? "")
            setRecents(user: user, uid: uid, pic: pic, date: date, msg: msg)
            return
        }
        
        if !snap!.exists {
            setRecents(user: user, uid: uid, pic: pic, date: date, msg: msg)
        }
        else {
            updateRecents(uid: uid, lastMsg: msg, date: date)
        }
    }
    
    updateDB(uid: uid, msg: msg, date: date)
}

func setRecents(user: String, uid: String, pic: String, date: Date, msg: String) {
    
    let db = Firestore.firestore()
    let myUid = Auth.auth().currentUser?.uid
    
    let myName  = UserDefaults.standard.value(forKey: "username") as! String
    let myPic   = UserDefaults.standard.value(forKey: "pic") as! String
    
    db.collection("users").document(uid).collection("recents").document(myUid!)
        .setData(["name": myName, "pic": myPic, "lastmsg": msg, "date": date]) {
            (err) in
            
            if err != nil {
                print(err?.localizedDescription ?? "")
                return
            }
        }
    
    db.collection("users").document(myUid!).collection("recents").document(uid)
        .setData(["name": user, "pic": pic, "lastmsg": msg, "date": date]) {
            (err) in
            
            if err != nil {
                print(err?.localizedDescription ?? "")
                return
            }
        }
}

func updateRecents(uid: String, lastMsg: String, date: Date) {
    let db = Firestore.firestore()
    let myUid = Auth.auth().currentUser?.uid
    
    db.collection("users").document(uid).collection("recents").document(myUid!).updateData(["lastMsg": lastMsg, "date": date])
    
    db.collection("users").document(myUid!).collection("recents").document(uid).updateData(["lastMsg": lastMsg, "date": date])
}

func updateDB(uid: String, msg: String, date: Date) {
    let db = Firestore.firestore()
    let myUid = Auth.auth().currentUser?.uid
    
    db.collection("msgs").document(uid).collection(myUid!).document()
        .setData(["msg": msg, "user": myUid!, "date": date]) {
            (err) in
            
            if err != nil {
                print(err?.localizedDescription ?? "")
                return
            }
        }
    
    db.collection("msgs").document(myUid!).collection(uid).document()
        .setData(["msg": msg, "user": myUid!, "date": date]) {
            (err) in
            
            if err != nil {
                print(err?.localizedDescription ?? "")
                return
            }
        }
}
