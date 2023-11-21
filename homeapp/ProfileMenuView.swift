//
//  ProfileMenuView.swift
//  homeapp
//
//  Created by HIRO on 2023/11/18.
//

import Foundation
import SwiftUI
struct ProfileMenuView: View {
    @State private var showAlert = false
    @EnvironmentObject var AppLoginUserInfo: LoginUserInfo
    @State private var activie = false
    @State private var backgroundColor = UIColor.white

    var body: some View {
        Spacer()
        NavigationStack{
            ZStack{
                Color(backgroundColor)
                    .ignoresSafeArea()
                VStack{
                    Button {
                        activie.toggle()
                    } label: {
                        HStack{
                            Text("メールアドレス変更")
                        }
                    }

                }
            }.buttonStyle(.bordered)
                .navigationDestination(isPresented: $activie, destination: {
                    ChangeMail()
                })
        }
        
        // todo あとで削除　強制ログアウトボタン
        Button(action: {
            do {
                if try logout(AppLoginUserInfo: AppLoginUserInfo) {
                    print("ログアウト成功")
                }
            } catch {
                print("Failed to sign out")
            }
        }){
            Text("ログアウト")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(20.0)
        }
    }
}
