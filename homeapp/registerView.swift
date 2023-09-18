//
//  registerView.swift
//  homeapp
//
//  Created by HIRO on 2023/08/22.
//

import SwiftUI

struct registerView: View {
    @State var email = ""
    @State var password = ""
    var body: some View {
        VStack(){
            Text("新規登録")
                .font(.largeTitle).foregroundColor(Color.black)
                .padding([.top, .bottom], 40)
            TextField("Email", text:self.$email)
                .padding()
                .cornerRadius(20.0)
            TextField("Password", text:self.$password)
                .padding()
                .cornerRadius(20.0)
            Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
                Text("登録")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15.0)
            }
        }
    }
}

struct registerView_Previews: PreviewProvider {
    static var previews: some View {
        registerView()
    }
}
