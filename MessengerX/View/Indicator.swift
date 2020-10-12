//
//  Indicator.swift
//  MessengerX
//
//  Created by Osama on 07/10/2020.
//

import SwiftUI

struct Indicator: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<Indicator>) -> some UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
