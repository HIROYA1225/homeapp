//
//  homeView.swift
//  homeapp
//
//  Created by HIRO on 2023/08/22.
//

import SwiftUI
import Liquid

struct homeView: View {
    @State private var isPlay = false

    //ログイン情報
    @EnvironmentObject var AppLoginUserInfo: LoginUserInfo

    var body: some View {
        VStack {
            ZStack{
                Liquid()
                    .frame(width: 240, height: 240)
                    .foregroundColor(isPlay ? .pink : .blue)
                    .opacity(0.3)
                
                Liquid()
                    .frame(width: 220, height: 220)
                    .foregroundColor(isPlay ? .pink : .blue)
                    .opacity(0.5)
                
                Liquid()
                    .frame(width: 200, height: 200)
                    .foregroundColor(isPlay ? .pink : .blue)
                    .opacity(0.6)
            }
            .padding(.bottom,100)
            Button(action:{
                self.isPlay = !isPlay
            }){
                Image(systemName: "speaker.wave.3.fill")
            }
        }
        .onAppear {
            Task {
                do {
                    // ユーザ情報取得
                    let result = try await getLoginUserInfo(AppLoginUserInfo: AppLoginUserInfo)
                    if !result {
                        // todo ログアウトとログイン画面へ遷移
                    } else {
                        // プロフィール画像取得
                        try await getProfileImage(AppLoginUserInfo: AppLoginUserInfo)
                    }

                } catch {
                    print(error)
                    // todo エラーアラート表示とログイン画面へ遷移
                }
            }
        }
    }
}

struct homeView_Previews: PreviewProvider {
    static var previews: some View {
        homeView()
    }
}
