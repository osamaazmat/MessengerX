//
//  SecondPage.swift
//  MessengerX
//
//  Created by Osama on 07/10/2020.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SecondPage: View {
    
    @Binding var show: Bool
    @Binding var ID: String
    
    @State var code     = ""
    @State var msg      = ""
    @State var alert    = false
    @State var creation = false
    @State var loading  = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { _ in
                VStack(spacing: 20) {
                    Spacer()
                    Image("Login")
                    Text("Verification Code").font(.largeTitle).fontWeight(.heavy)
                    Text("Please Enter The Verification Code")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 12)
                    
                    TextField("Code", text: $code)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color("Color"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, 15)
                    
                    
                    if self.loading {
                        HStack {
                            Spacer()
                            Indicator()
                            Spacer()
                        }
                    }
                    else {
                        Button(action: {
                            let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.ID, verificationCode: self.code)
                            
                            self.loading.toggle()
                            
                            Auth.auth().signIn(with: credential) { (res, err) in
                                if err != nil {
                                    self.msg = (err?.localizedDescription)!
                                    self.alert.toggle()
                                    self.loading.toggle()
                                    return
                                }
                                
                                checkUser { (exists, userName, uid, pic) in
                                    if exists {
                                        UserDefaults.standard.set(true, forKey: "status")
                                        UserDefaults.standard.set(userName, forKey: "username")
                                        UserDefaults.standard.set(uid, forKey: "UID")
                                        UserDefaults.standard.set(pic, forKey: "pic")
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "statusChanged"), object: nil)
                                    }
                                    else {
                                        self.loading.toggle()
                                        self.creation.toggle()
                                    }
                                }
                            }
                            
                        }) {
                            Text("Verify").frame(width: UIScreen.main.bounds.width - 30, height: 50)
                        }
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                }
            }
            
            Button(action: {
                self.show.toggle()
            }) {
                Image(systemName: "chevron.left").font(.title)
            }
            .foregroundColor(.orange)
        }
        .padding()
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Okay")))
        }
        .sheet(isPresented: self.$creation) {
            AccountCreation(show: self.$creation)
        }
    }
}
