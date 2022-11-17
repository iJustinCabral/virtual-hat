//
//  CountView.swift
//  VirtualHat
//
//  Created by Justin Cabral on 7/19/20.
//

import SwiftUI

struct CountView: View {
    var count: Int
        
    var body: some View {
        Text("Names Remaining: \(count)")
            .fontWeight(.bold)
            .padding(.all, 8)
            .background(Color("AccentColor"))
            .foregroundColor(Color.white)
            .clipShape(Capsule())
            .shadow(radius: 3)
            .transition(.scale)
    }
}

struct CountView_Previews: PreviewProvider {
    static var previews: some View {
        CountView(count: 0)
    }
}
