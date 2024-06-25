import SwiftUI


struct ContentView: View {
    @State private var selection: Tab = .featured
    
    @State private var viewModel = ViewModel()


    enum Tab: String {
        case featured
        case list
        case shot
        case record
    }


    var body: some View {
        TabView(selection: $selection) {
            CategoryHome()
                .tabItem {
                    Label("Featured", systemImage: "star")
                }
                .tag(Tab.featured)


            LandmarkList()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                .tag(Tab.list)
            
            CameraView(image: $viewModel.currentFrame)
                .tabItem {
                    Label("Shot", systemImage: "camera")
                }
                .tag(Tab.shot)
            VideoRecorderView()
                .tabItem {
                    Label("Record", systemImage: "iphone.gen1.landscape")
                }
                .tag(Tab.record)
        }
    }
}


#Preview {
    ContentView()
        .environment(ModelData())
}

