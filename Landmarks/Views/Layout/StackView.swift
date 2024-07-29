//
//  StackView.swift
//  Landmarks
//
//  Created by Elias on 2024/7/26.
//

import SwiftUI

struct StackView: View {
    var body: some View {
        VStack() {
            Rectangle()
                .fill(Color.red)
                .frame(width: 300, height: 200)
            Rectangle()
                .fill(Color.green)
                .frame(width: 300, height: 200)
        }
    }
}

#Preview {
    StackView()
}
