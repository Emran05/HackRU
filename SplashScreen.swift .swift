import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            SetDestinationView()
        } else {
            VStack {
                Image("GeoBuzzerIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()

                Text("GeoBuzzer")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
