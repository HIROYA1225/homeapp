import SwiftUI
import AVFoundation

struct playView3: View {
    
    // 音声プレイヤーのインスタンス化
    // 音声の平均パワーを格納する配列
    @State var powerLevels: [Float] = []
    // タイマー
    @State var timer: Timer?
    
    var body: some View {
        
        // 音声ファイルの読み込み
        let audioFile = Bundle.main.url(forResource: "announce", withExtension: "mp3")!
        let audioPlayer = try! AVAudioPlayer(contentsOf: audioFile)
        VStack {
            // 音声ビジュアライザーを表示する
            SoundVisualizer(powerLevels: powerLevels)
                .frame(height: 300)
            
            // 再生ボタンを表示する
            Button(action: {
                // 音声を再生する
                audioPlayer.play()
                // タイマーを開始する
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    // 音声の平均パワーを取得する
                    audioPlayer.updateMeters()
                    let power = audioPlayer.averagePower(forChannel: 0)
                    // 配列に追加する
                    powerLevels.append(power)
                    // 配列の要素数が20を超えたら、先頭の要素を削除する
                    if powerLevels.count > 10 {
                        powerLevels.removeFirst()
                    }
                }
            }) {
                Text("Play")
                    .font(.largeTitle)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        // 音声プレイヤーのメータリングを有効にする
        .onAppear {
            audioPlayer.isMeteringEnabled = true
        }
        // タイマーを停止する
        .onDisappear {
            timer?.invalidate()
        }
    }
}

// 音声ビジュアライザーを定義する
struct SoundVisualizer: View {
    // 音声の平均パワーを受け取る
    let powerLevels: [Float]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            // 配列の要素数分だけ繰り返す
            ForEach(powerLevels, id: \.self) { level in
                // パワーに応じて高さを変える
                let height = CGFloat(level + 100) * 1
                // 矩形を描く
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 10, height: height)
            }
        }
    }
}

struct playView3_Previews: PreviewProvider {
    static var previews: some View {
        playView3()
    }
}
