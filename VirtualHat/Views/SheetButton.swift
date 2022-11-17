//
//  SheetButton.swift
//  VirtualHat
//
//  Created by Justin Cabral on 7/19/20.
//

import SwiftUI

struct SheetButton<Content>: View where Content : View {

    var text: String
    var content: Content
    @State var isPresented = false

    init(_ text: String, @ViewBuilder content: () -> Content) {
        self.text = text
        self.content = content()
    }

    var body: some View {
        Button(text) {
            self.isPresented.toggle()
        }
        .sheet(isPresented: $isPresented) {
            self.content
        }
    }
}
