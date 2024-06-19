import SwiftUI


struct ContentView: View {
    @State private var selection: Tab = .featured
    
    @State private var viewModel = ViewModel()


    enum Tab: String {
        case featured
        case list
        case shot
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
        }
    }
}


#Preview {
    ContentView()
        .environment(ModelData())
}

