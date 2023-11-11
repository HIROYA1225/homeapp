//
//  playView2.swift
//  homeapp
//
//  Created by HIRO on 2023/10/23.
//

import SwiftUI

struct playView2: View {
    // 円の半径
    @State var radius: CGFloat = 50
    // 水波の半径
    @State var waveRadius: CGFloat = 0
    // 水波の透明度
    @State var waveOpacity: Double = 1
    
    var body: some View {
        ZStack {
            // 円を描く
            Circle()
                .fill(Color.blue)
                .frame(width: radius * 2, height: radius * 2)
            
            // 水波を描く
            Circle()
                .stroke(Color.blue, lineWidth: 5)
                .frame(width: waveRadius * 2, height: waveRadius * 2)
                .opacity(waveOpacity)
                // アニメーションを設定する
                .animation(Animation.linear(duration: 5).repeatForever(autoreverses: false))
        }
        // 中央に配置する
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // ボタンを押したときのアクションを定義する
        .onTapGesture {
            // 水波の半径と透明度を初期化する
            waveRadius = radius
            waveOpacity = 0.1
            // 水波の半径と透明度を変化させる
            withAnimation {
                waveRadius = radius * 3
                waveOpacity = 0
            }
        }
    }
}

struct playView2_Previews: PreviewProvider {
    static var previews: some View {
        playView2()
    }
}
