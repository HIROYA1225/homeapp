//
//  SideMenuTest.swift
//  homeapp
//
//  Created by HIRO on 2023/11/19.
//

import Foundation
import SwiftUI
struct SideMenuTest: View {
    @State var isOpenSideMenu: Bool = false
    var body: some View {
        NavigationView {
            ZStack{
                Color.clear
                VStack{
                    Text("Hello, World!")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .padding()
                    
                    Spacer()
                }
                if isOpenSideMenu {
                    SideMenuView(isOpen: $isOpenSideMenu)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.move(edge: .leading))
                        .animation(.easeInOut(duration: 0.25))
                }
            }
            .navigationBarItems(leading: (
                Button(action: {
                    self.isOpenSideMenu.toggle()
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                }
            ))
        }
    }
}

struct SideMenuView: View {
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
                    NavigationLink(destination: ChangeMailAddress()) {
                        SideMenuContentView(topPadding: 100, systemName: "person", text: "Profile")
                    }
                    NavigationLink(destination: ChangePass()) {
                        SideMenuContentView(systemName: "bookmark", text: "Bookmark")
                    }
                    NavigationLink(destination: RegisterPremium()) {
                        SideMenuContentView(systemName: "gear", text: "Setting")
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
    var systemName: String
    var text: String
    var body: some View {
        HStack {
            Image(systemName: systemName)
                .foregroundColor(.gray)
                .imageScale(.large)
                .frame(width: 35)
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
//プレビュー表示
struct SideMenuTest_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuTest()
    }
}

