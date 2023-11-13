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
        //==================================
//        // todo あとで削除　強制ログアウトボタン
//        Button(action: {
//            do {
//                if try logout(AppLoginUserInfo: AppLoginUserInfo) {
//                    print("ログアウト成功")
//                }
//            } catch {
//                print("Failed to sign out")
//            }
//        }){
//            Text("テスト用ログアウトボタン")
//                .font(.headline)
//                .foregroundColor(.white)
//                .padding()
//                .background(Color.red)
//                .cornerRadius(15.0)
//        }
        //==================================
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
            // 初期処理
            Task {
                do {
                    // ユーザ情報取得
                    let result = try await getLoginUserInfo(AppLoginUserInfo: AppLoginUserInfo)
                    if !result {
                        // todo ログアウト処理とログイン画面へ遷移
                    } else {
                        // プロフィール画像取得
                        let image = try await getProfileImage(AppLoginUserInfo: AppLoginUserInfo)
                        AppLoginUserInfo.profileImage = image
                    }
                } catch CustomError.genericError(let errorMessage) {
                    print(errorMessage)
                    // todo エラーアラート表示(ログイン情報取得でエラーになりましたのような)とログイン画面へ遷移
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
