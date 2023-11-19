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
    
    @State private var isShowSheet = false

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
            VStack(){
                Button(action:{
                    self.isPlay = !isPlay
                }){
                    Image(systemName: "speaker.wave.3.fill")
                }
                .padding(.bottom,10)
                Button("評価ボタン") {
                    isShowSheet.toggle()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(20.0)
                .sheet(isPresented: $isShowSheet) {

                    HalfModalView(isPresented: $isShowSheet)
                        .presentationDetents([.medium]) // ⬅︎
                }
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
struct HalfModalView: View {
    @Binding var isPresented: Bool
    @State private var selectedNumber = 0
    @State private var comment = ""
    @State private var isReport = false

    var body: some View {
        VStack {
            Spacer()

            VStack() {
                Button(action:{
                    isReport = true
                }){
                    Image(systemName: "bell.fill")
                }
                NavigationLink(destination: reportView(), isActive: $isReport) {
                    EmptyView()
                }
                Picker("Number", selection: $selectedNumber) {
                    ForEach(0..<6) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .labelsHidden()
                .pickerStyle(WheelPickerStyle())

                TextField("Comment", text: $comment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                HStack {
                    Button("評価") {
                        print("Number: \(selectedNumber), Comment: \(comment)")
                        isPresented = false
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)

                    Button("キャンセル") {
                        isPresented = false
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)
            .background(Color.white)
            .cornerRadius(20)
        }
    }
}
