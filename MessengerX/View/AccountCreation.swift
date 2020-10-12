//
//  AccountCreation.swift
//  MessengerX
//
//  Created by Osama on 07/10/2020.
//

import SwiftUI

struct AccountCreation: View {
    
    @Binding var show: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State var name             = ""
    @State var about            = ""
    @State var picker           = false
    @State var loading          = false
    @State var imageData: Data  = .init(count: 0)
    @State var alert            = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            Text("Create Account").font(.title)
            
            HStack {
                Spacer()
                Button {
                    self.picker.toggle()
                } label: {
                    if self.imageData.count == 0 {
                        Image(systemName: "person.crop.circle.badge.plus").resizable().frame(width: 90, height: 70).foregroundColor(.gray).aspectRatio(contentMode: .fill)
                    }
                    else {
                        Image(uiImage: UIImage(data: self.imageData)!).resizable().renderingMode(.original).frame(width: 90, height: 90).clipShape(Circle())
                    }
                }
                Spacer()
            }
            .padding(.vertical, 15)
            
            Text("Enter User Name")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, 12)
            TextField("Name", text: $name)
                .keyboardType(.numberPad)
                .padding()
                .background(Color("Color"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text("Enter About")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, 12)
            TextField("About", text: $about)
                .keyboardType(.numberPad)
                .padding()
                .background(Color("Color"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if self.loading {
                HStack {
                    Spacer()
                    Indicator()
                    Spacer()
                }
            }
            else {
                Button(action: {
                    self.loading.toggle()
                    if self.name != "" && self.about != "" && self.imageData.count != 0 {
                        createUser(for: self.name, and: self.about, with: self.imageData) { (status) in
                            if status {
                                self.show.toggle()
                                self.presentationMode.wrappedValue.dismiss()
                                self.loading.toggle()
                            }
                        }
                    }
                    else {
                        self.loading.toggle()
                        self.alert.toggle()
                    }
                    
                }) {
                    Text("Create").frame(width: UIScreen.main.bounds.width - 30, height: 50)
                }
                .foregroundColor(.white)
                .background(Color.orange)
                .cornerRadius(10)
            }
            
            
        }
        .padding()
        .sheet(isPresented: self.$picker, content: {
            ImagePicker(picker: self.$picker, imageData: self.$imageData)
        })
        .alert(isPresented: $alert) {
            Alert(title: Text("Message"), message: Text("Please fill the contents"), dismissButton: .default(Text("Okay")))
        }
    }
}
