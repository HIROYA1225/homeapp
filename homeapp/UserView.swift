//
//  UserView.swift
//  homeapp
//
//  Created by YOSUKE on 2023/11/24.
//

import SwiftUI

struct UserView: View {
    @State private var period = ""
    
    let period_list = ["総合", "年間", "月間", "週間"]
    let message = "皆さんの心の友になれるような褒め言葉をお届けします！"
    let userName = "ユーザーA"
    let userAge = 28
    let userGender = "男性"
    let userLocation = "愛知県"
    let heartNum = 5555
    
    private let width:CGFloat = 120
    @State private var showingAlert = false   // アラートの表示フラグ
    
    var body: some View {
        NavigationView {        // 画面遷移用
            VStack(spacing:20){
                // ユーザー基本情報
                VStack(spacing:5){
                    HStack(spacing:10){
                        Image(systemName: "person.crop.circle")     //ユーザーアイコン
                            .resizable()
                            .scaledToFit()
                            .frame(width: width*2/3, height: width*2/3)
                            .foregroundColor(.black)
                        VStack{
                            Text(userName)    //ユーザー名
                                .font(.title)
                            HStack{
                                Text(String(userAge))    // 年齢
                                Text(userGender)    // 性別
                                Text(userLocation)    // 居住地
                            }
                            .font(.body)
                        }
                    }
                    // 合計いいね表示
                    HStack{
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width*0.2, height: width*0.2)
                            .foregroundColor(.red)
                        Text(String(heartNum))  // いいね数表示
                            .font(.headline)
                        
                    }
                    // ユーザメッセージ
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .frame(width: screenWidth*0.7, height: 100)
                        .font(.body)
                }
                
                // 会員登録画面への遷移　※未完成
                NavigationLink(destination: MembershipView()) {
                    Text("会員登録画面")
                }
                
                // 音声表示
                VStack(spacing:0){
                    ForEach((1...5), id: \.self) { num in
                        // 音声1行表示
                        HStack(spacing:10){
                            Text(String(num)) //順位
                            Text("音声"+String(num))
                            Spacer()
                            Image(systemName: "heart.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: width/6, height: width/6)
                                .foregroundColor(.red)
                            Text("1111")    //いいね数
                            // 音声再生ボタン
                            Button(action: {
                                            //再生画面表示
                                showingAlert = true     //アラート表示フラグON
                            }){
                                Image(systemName: "play.circle.fill")   // 再生ボタン画像
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    .foregroundColor(.blue)
                            }
                            .alert(isPresented: $showingAlert, content: {
                                Alert(title: Text("音声の再生には有料会員登録が必要です。"),
                                      primaryButton: .cancel(Text("キャンセル")),     // 左ボタンの設定
                                      secondaryButton: .default(Text("会員登録"),    // 右ボタンの設定
                                                                action: {
                                    // 課金画面へ遷移
                                }))
                            })
                        }
                        .font(.headline)    // フォント
                        .frame(width: width*2, height: 30) //各音声行の枠サイズ
                        .foregroundColor(.black)    // 文字色
                        .padding()
                        .background(Color.mint)     // 背景色
                        .border(Color.black)    // 枠線
                    }
                }
            }
        }
    }
}


struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
