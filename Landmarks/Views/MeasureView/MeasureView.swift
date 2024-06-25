import SwiftUI

struct MeasureView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: Recording()) {
                    Text("Start")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                }
            }
            .navigationBarTitle("Home")
        }
    }
}

#Preview {
    MeasureView()
}

