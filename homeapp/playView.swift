//
//  playView5.swift
//  homeapp
//
//  Created by HIRO on 2023/10/31.
//
import SwiftUI
import AVFoundation

struct PlayView: View {
    // 音声ファイルのURL
    let audioURL = Bundle.main.url(forResource: "mp3/announce", withExtension: "mp3")!

    // 音声プレイヤー
    @State var audioPlayer: AVAudioPlayer?

    // 音声の平均パワー
    @State var averagePower: Float = 0

    // タイマー
    @State var timer: Timer?

    // ボタンのテキスト
    @State var buttonText = "Play"

    var body: some View {
        VStack {
            // 円の描画
            Circle()
                .stroke(lineWidth: 2)
                .frame(width: 200, height: 200)
                // 円の縁のアニメーション
                .scaleEffect(1 + CGFloat(averagePower) / 100)
                .animation(.easeInOut(duration: 0.1))

            // ボタンの描画
            Button(action: {
                // ボタンが押されたときの処理
                if self.audioPlayer == nil {
                    // 音声プレイヤーを初期化
                    self.initAudioPlayer()
                }

                if self.audioPlayer?.isPlaying == true {
                    // 音声が再生中なら停止する
                    self.audioPlayer?.stop()
                    self.timer?.invalidate()
                    self.buttonText = "Play"
                } else {
                    // 音声が停止中なら再生する
                    self.audioPlayer?.play()
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                        // タイマーで定期的に音声の平均パワーを更新する
                        self.updateAveragePower()
                    }
                    self.buttonText = "Stop"
                }
            }) {
                Text(buttonText)
                    .font(.largeTitle)
            }
        }
    }

    // 音声プレイヤーを初期化する関数
    func initAudioPlayer() {
        do {
            // 音声プレイヤーを作成する
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()
            // メータリングを有効にする
            audioPlayer?.isMeteringEnabled = true
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    // 音声の平均パワーを更新する関数
    func updateAveragePower() {
        // 現在のチャンネルの平均パワーを取得する
        audioPlayer?.updateMeters()
        averagePower = audioPlayer?.averagePower(forChannel: 0) ?? 0

        // 平均パワーが-160以下なら0にする（無音に近い）
        if averagePower < -160 {
            averagePower = 0
        }

        print("Average power: \(averagePower)")
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
    }
}
