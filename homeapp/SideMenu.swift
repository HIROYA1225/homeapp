//
//  SideMenuTest.swift
//  homeapp
//
//  Created by HIRO on 2023/11/19.
//

import Foundation
import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var AppLoginUserInfo: LoginUserInfo
    @Binding var isOpen: Bool
    let width: CGFloat = 270
    var body: some View {
        ZStack {
            // 背景部分
            GeometryReader { geometry in
                EmptyView()
            }
            .background(Color.gray.opacity(0.3))
            .opacity(self.isOpen ? 1.0 : 0.0)
            .animation(.easeIn(duration: 0.25))
            .onTapGesture {
                self.isOpen = false
            }
            // リスト部分
            HStack {
                VStack() {
                    NavigationLink(destination: SettingView()) {
                        SideMenuContentView(topPadding: 200,text: "設定")
                    }

                    Spacer()
                }
                .frame(width: width)
                .background(Color(UIColor.systemGray6))
                .offset(x: self.isOpen ? 0 : -self.width)
                .animation(.easeIn(duration: 0.25))
                Spacer()
            }
        }
    }
}
struct SideMenuContentView: View {
    var topPadding: CGFloat = 0
    var text: String
    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(.gray)
                .font(.headline)
            Spacer()
        }
        .padding(.top, topPadding)
        .padding(.bottom, 20)
        .padding(.leading, 20)
        .padding(.trailing, 70)
    }
}
