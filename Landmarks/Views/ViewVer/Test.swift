//
//  Test.swift
//  Landmarks
//
//  Created by Elias on 2024/7/23.
//

import SwiftUI

struct ContentViewAa: View {
    @State private var timerCount: Int = 0
    @State private var timer: Timer? = nil

    var body: some View {
            ZStack {
                // 左上角的计时器
                VStack {
                    HStack {
                        Text("Timer: \(timerCount)")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .rotationEffect(.degrees(90))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    Spacer()
                }
                .padding()

                // 底部中心的按钮
                HStack {
                    Button(action: {
                        startTimer()
                    }) {
                        Text("Start Timer")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                }
                .rotationEffect(.init(degrees: 90))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .onAppear {
                startTimer()
            }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timerCount += 1
        }
    }
}

#Preview {
    ContentViewAa()
        .previewInterfaceOrientation(.landscapeLeft)
}
