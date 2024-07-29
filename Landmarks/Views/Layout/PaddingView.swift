//
//  PaddingView.swift
//  Landmarks
//
//  Created by Elias on 2024/7/26.
//

import SwiftUI

struct PaddingView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .padding(20)
            .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
            .frame(width: 300, height: 300)
            .border(Color.red)
    }
}

#Preview {
    PaddingView()
}
