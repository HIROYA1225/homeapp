//
//  loginView.swift
//  homeapp
//
//  Created by HIRO on 2023/08/22.
//

import SwiftUI

struct loginView: View {
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        VStack(){
            Text("褒めアプテスト")
                .font(.largeTitle).foregroundColor(Color.black)
                .padding([.top, .bottom], 40)
            TextField("Email", text:self.$email)
                .padding()
                .cornerRadius(20.0)
            TextField("Password", text:self.$password)
                .padding()
                .cornerRadius(20.0)
            
            HStack(){
                Button(action:{}){
                    Image("Google_icon")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                Button(action:{}){
                    Image("LINE_icon")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            HStack(){
                Button(action:{}){
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15.0)
                }
                Button(action:{}){
                    Text("新規登録")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15.0)
                }
                
            }
        }
    }
}

struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        loginView()
    }
}
