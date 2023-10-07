//
//  ProfileView.swift
//  homeapp
//
//  Created by Yosuke on 2023/09/20.
//

import SwiftUI

struct ProfileView: View {
    @State private var userName = ""
    @State private var gender = ""
    @State private var age = ""
    @State private var residence = ""
    @State private var introduction = ""
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
    let genders = ["男性", "女性", "その他"]
    private let Rec_width:CGFloat = 120
    private let Item_width:CGFloat = 92
    
    //画面触ったらキーボード閉じる処理の準備
    enum Field: Hashable {
        case userName
        case age
        case introduction
    }
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing:30){

            HStack{
                Button(action:{}){
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.black)
                }
            }

            HStack{
                    Text("Name")
                        .frame(width: Item_width, height: 15, alignment:.leading)
                VStack{
                    TextField("", text:self.$userName)
                        .keyboardType(.default)
                        .frame(width: Rec_width, height: 15)
                        //画面触ったらキーボード閉じる処理
                        .focused($focusedField, equals: .userName)
                        .onTapGesture {
                           focusedField = .userName
                        }
                    Rectangle()
                        .frame(width: Rec_width,height: 1.5)
                        .foregroundColor(.black)
                }
            }
            
            HStack{
                Text("Gender")
                    .frame(width: Item_width, height: 15, alignment:.leading)
                VStack{
                    Picker("", selection: self.$gender) {
                        ForEach(genders, id: \.self) { item in
                            Text(item)
                        }
                    }
                    .frame(width: Rec_width, height: 15, alignment:.leading)
                    Rectangle()
                        .frame(width: Rec_width,height: 1.5).foregroundColor(.black)
                }
            }
            
            HStack{
                Text("Age")
                    .frame(width: Item_width, height: 15, alignment:.leading)
                VStack{
                    TextField("", text:self.$age)
                        .keyboardType(.numberPad)
                        .frame(width: Rec_width, height: 15)
                        //画面触ったらキーボード閉じる処理
                        .focused($focusedField, equals: .age)
                        .onTapGesture {
                           focusedField = .age
                        }
                    Rectangle()
                        .frame(width: Rec_width,height: 1.5).foregroundColor(.black)
                }
            }
            
            HStack{
                Text("Location")
                    .frame(width: Item_width, height: 15, alignment:.leading)
                VStack{
                    Picker("", selection: self.$residence) {
                        ForEach(prefectures, id: \.self) { item in
                            Text(item)
                        }
                    }
                    .frame(width: Rec_width, height: 15, alignment:.leading)
                    Rectangle()
                        .frame(width: Rec_width,height: 1.5).foregroundColor(.black)
                }
            }
            
            VStack{
                Text("About")
                    .frame(width: 220, height: 15, alignment:.leading)
                TextEditor(text:self.$introduction)
                    .keyboardType(.default)
                    .frame(width: 220,height: 150,alignment: .topLeading)
                    .border(Color.black,width: 1)
                    //画面触ったらキーボード閉じる処理
                    .focused($focusedField, equals: .introduction)
                    .onTapGesture {
                       focusedField = .introduction
                    }
            }
            
            HStack(){
                Button(action:{}){
                    Text("決定")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(20.0)
                }
            }
        }
        //画面触ったらキーボード閉じる処理
        .onTapGesture {
            focusedField = nil
        }
    }
}

//プレビュー表示
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
