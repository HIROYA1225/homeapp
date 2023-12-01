//
//  MembershipView.swift
//  homeapp
//
//  Created by YOSUKE on 2023/11/24.
//

import SwiftUI

struct MembershipView: View {
    @State private var period = ""

    let list = ["無制限の褒め言葉再生",
                "お気に入りのホメラーの褒め言葉の再生",
                "無制限の褒め言葉録音"]
    let message = "皆さんの心の友になれるような褒め言葉をお届けします！"
    let userName = "ユーザーA"
    let userAge = 28
    let userGender = "男性"
    let userLocation = "愛知県"
    let heartNum = 5555
    
    private let width:CGFloat = 120
    @State private var showingAlert = false   // アラートの表示フラグ
    
    var body: some View {
        VStack(spacing:40){
                // ユーザー基本情報
                VStack(spacing:5){
                    HStack(spacing:5){
                        VStack{
                            Text("980円/月")    // 月額価格
                                .font(.largeTitle)
                            Text("現在のプラン:無料")    // 現在のプラン
                                .font(.body)
                                .frame(width: screenWidth*0.5, height: 20)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.mint)
                                .cornerRadius(20.0)
                            Text("有料会員になって、無制限に褒め言葉を聴こう！")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .frame(width: screenWidth*0.8, height: 100)
                                .font(.body)
                        }
                    }
            
                }
                        
            // できること表示
            VStack(spacing: 0){
                Rectangle()     // 囲い線
                    .frame(width: screenWidth*0.5,height: 1).foregroundColor(.black)
                ForEach((0...2), id: \.self) { num in
                    HStack(spacing:10){
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green)
                        Text(list[num])    // できること文言表示
                        Spacer()
                    }
                    .font(.headline)    // フォント
                    .frame(width: screenWidth*0.7, height: 50) //できることの枠サイズ
                    .foregroundColor(.black)    // 文字色
                    .padding()
                    .background(Color.white)     // 背景色
                }
                Rectangle()     // 囲い線
                    .frame(width: screenWidth*0.5,height: 1).foregroundColor(.black)

            }
            
            // 有料会員登録ボタン
            Button(action: {
                showingAlert = true
            }){
                Text("有料会員登録")
                    .frame(width: screenWidth*0.3, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.black)
                    .cornerRadius(30.0)
            }
            .alert(isPresented: $showingAlert, content: {
                Alert(title: Text("登録完了"),
                      primaryButton: .cancel(Text("キャンセル")),     // 左ボタンの設定
                      secondaryButton: .default(Text("OK")))    // 右ボタンの設定
            })
        }
    }
}

struct MembershipView_Previews: PreviewProvider {
    static var previews: some View {
        MembershipView()
    }
}
