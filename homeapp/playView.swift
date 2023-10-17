
import SwiftUI
import Liquid

struct playView: View {
    @State private var showRipple = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    showRipple.toggle()
                }
            }) {
                Text("アニメーションを開始")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: 200, height: 200)
                
                if showRipple {
                    RippleAnimation()
                }
            }
        }
    }
}

struct RippleAnimation: View {
    @State private var scale: CGFloat = 0.1
    
    var body: some View {
        Circle()
            .fill(Color.blue.opacity(0.5))
            .frame(width: 150, height: 150)
            .scaleEffect(scale)
            .opacity(1 - Double(scale))
            .animation(
                Animation.easeOut(duration: 5)
                    .repeatForever(autoreverses: false)
            )
            .onAppear() {
                self.scale = 1.0
            }
    }
}

struct playView_Previews: PreviewProvider {
    static var previews: some View {
        playView()
    }
}
