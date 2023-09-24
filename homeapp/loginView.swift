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
    @State private var active = false
    var body: some View {
        NavigationStack{
            VStack(alignment: .center){
                Text("褒めアプテスト")
                    .font(.largeTitle).foregroundColor(Color.black)
                    .padding([.top, .bottom], 40)
                TextField("Email", text:self.$email)
                    .padding()
                    .cornerRadius(20.0)
                TextField("Password", text:self.$password)
                    .padding()
                    .cornerRadius(20.0)
                
                HStack(spacing: 20){
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
                .padding(.bottom,20)
                .offset(x:-5)
                HStack(){
                    Button(action:{
                        active.toggle()
                    }){
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15.0)
                    }
                    .navigationDestination(isPresented: $active, destination: {
                        registerView()
                    })
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
}

struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        loginView()
    }
}
