//
//  GridentsView.swift
//  Landmarks
//  渐变
//  Created by Elias on 2024/7/24.
//

import SwiftUI

struct GridentsView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .fill(LinearGradient(gradient: /*@START_MENU_TOKEN@*/Gradient(colors: [Color.red, Color.blue])/*@END_MENU_TOKEN@*/, startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
            .frame(width: 300, height: 200)
    }
}

#Preview {
    GridentsView()
}
