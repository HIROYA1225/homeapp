//
//  ProfileView.swift
//  homeapp
//
//  Created by Yosuke on 2023/09/20.
//

import SwiftUI

struct ProfileView: View {
    @State private var name = ""
    @State private var gender = ""
    @State private var age = ""
    @State private var location = ""
    @State private var about = ""
    let prefectures = ["北海道", "青森県", "岩手県", "宮城県", "秋田県",
                       "山形県", "福島県", "茨城県", "栃木県", "群馬県",
                       "埼玉県", "千葉県", "東京都", "神奈川県","新潟県",
                       "富山県", "石川県", "福井県", "山梨県", "長野県",
                       "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県",
                       "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県",
                       "鳥取県", "島根県", "岡山県", "広島県", "山口県",
                       "徳島県", "香川県", "愛媛県", "高知県", "福岡県",
                       "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県",
                       "鹿児島県", "沖縄県"]
    
    var body: some View {
        VStack(spacing:30){

            HStack(){
                Button(action:{}){
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.black)
                }
            }

            VStack{
                TextField("Name", text:self.$name)
                    .keyboardType(.default)
                    .cornerRadius(20.0)
                    .frame(width: 220, height: 15)
                Rectangle().frame(width: 220,height: 1.5).foregroundColor(.black)
            }
            VStack{
                HStack{
                    Text("Gender")
                        .frame(width: 155, height: 15)
                    Picker(selection:self.$gender, label: Text("Gender")){
                        Text("男性").tag(0)
                        Text("女性").tag(1)
                        Text("その他").tag(2)
                    }
                    .frame(width: 155, height: 15)
                }
                Rectangle().frame(width: 220,height: 1.5).foregroundColor(.black)
            }
            
            VStack{
                TextField("Age", text:self.$age)
                    .keyboardType(.numberPad)
                    .frame(width: 220, height: 15)
                Rectangle().frame(width: 220,height: 1.5).foregroundColor(.black)
            }
            
            VStack {
                HStack{
                    Text("Location")
                        .frame(width: 145, height: 15)
                    Picker("", selection: self.$location) {
                        ForEach(prefectures, id: \.self) { item in
                            Text(item)
                        }
                    }
                    .frame(width: 145, height: 15)
                }
                Rectangle().frame(width: 220,height: 1.5).foregroundColor(.black)
            }
            
            VStack{
                Text("About")
                    .frame(width: 220, height: 15, alignment:.leading)
                TextEditor(text:self.$about)
                    .keyboardType(.default)
                    .frame(width: 220,height: 150,alignment: .topLeading)
                    .border(Color.black,width: 1)
            }
            
            HStack(){
                Button(action:{}){
                    Text("決定")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(20.0)
                       // .frame(width: 220,height: 10)

                }
               // .frame(width: 220,height: 10)

            
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
