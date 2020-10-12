//
//  FirstPage.swift
//  MessengerX
//
//  Created by Osama on 07/10/2020.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct FirstPage: View {
    
    @State var cCode    = ""
    @State var number   = ""
    @State var show     = false
    @State var msg      = ""
    @State var alert    = false
    @State var ID       = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image("Login")
            Text("Verify Your Number").font(.largeTitle).fontWeight(.heavy)
            Text("Please Enter Your Number to Verify Your Account")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, 12)
            
            HStack {
                TextField("+1", text: $cCode)
                    .keyboardType(.numberPad)
                    .frame(width: 45)
                    .padding()
                    .background(Color("Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                TextField("Number", text: $number)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color("Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
            }.padding(.top, 15)
            
            NavigationLink(destination: SecondPage(show: $show, ID: $ID), isActive: $show) {
                Button(action: {
                    
                    PhoneAuthProvider.provider().verifyPhoneNumber("+" + self.cCode + self.number, uiDelegate: nil) { (ID, err) in
                        if err != nil {
                            self.msg = (err?.localizedDescription)!
                            self.alert.toggle()
                            return
                        }
                        else {
                            self.ID = ID!
                            self.show.toggle()
                        }
                    }
                }) {
                    Text("Send").frame(width: UIScreen.main.bounds.width - 30, height: 50)
                }
                .foregroundColor(.white)
                .background(Color.orange)
                .cornerRadius(10)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
        }
        .padding()
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Okay")))
        }
    }
}
