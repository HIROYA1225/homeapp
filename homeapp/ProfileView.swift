//
//  ProfileView.swift
//  homeapp
//
//  Created by Yosuke on 2023/09/20.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var email = ""

    @State private var userName = ""
    @State private var gender = ""
    @State private var age = ""
    @State private var residence = ""
    @State private var introduction = ""

    @State private var profileImageFileName = ""

    @State private var profileImage: Image?

    //ログイン情報
    @EnvironmentObject var AppLoginUserInfo: LoginUserInfo

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
                Button(action:{
                    Task {
                        do {
                            //todo test用==
                            email = AppLoginUserInfo.email
                            //==

                            //ユーザ情報変更
                            let success = try await updateUser(email: email, userName: userName, gender: gender, age: age, residence: residence, introduction: introduction)
                            if success {
                                print("成功")
                            } else {

                            }
                        }
                    }
                }){
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
        .onAppear() {
            //ログインユーザ情報取得
            getLoginUserInfo()
        }
        //画面触ったらキーボード閉じる処理
        .onTapGesture {
            focusedField = nil
        }
    }

    //ログインユーザ情報取得
    private func getLoginUserInfo() {

        //ユーザコレクション情報の取得
        self.email = AppLoginUserInfo.email
        self.userName = AppLoginUserInfo.userName
        self.gender = AppLoginUserInfo.gender
        self.age = AppLoginUserInfo.age
        self.residence = AppLoginUserInfo.residence
        self.introduction = AppLoginUserInfo.introduction
        self.profileImageFileName = AppLoginUserInfo.profileImageFileName

        //プロフィール画像の取得
        self.profileImage = AppLoginUserInfo.profileImage
    }

    //ユーザ情報変更
    // todo プロフィール画像の更新
    private func updateUser(email: String, userName: String, gender: String, age: String, residence: String, introduction: String) async throws -> Bool {

        return try await withCheckedThrowingContinuation { continuation in

            // 現在のemailを保持(ロールバック用)
            let currentEmail = Auth.auth().currentUser?.email

            //更新日時
            let currentDateTime = Date()
            let updateDateTime: Timestamp = Timestamp(date: currentDateTime)

            Auth.auth().currentUser?.updateEmail(to: email) { error in
                if let error = error {
                    print("ユーザ情報の変更失敗(Auth): \(error)")
                    continuation.resume(throwing: error)
                } else {
                    print("ユーザ情報の変更成功(Auth)")
                    // UIDを取得してFirestoreで他の情報を更新
                    if let uid = Auth.auth().currentUser?.uid {
                        let db = Firestore.firestore()
                        db.collection("users").document(uid).updateData([
                            "userName": userName,
                            "gender": gender,
                            "age": age,
                            "residence": residence,
                            "introduction": introduction,
                            "profileImgFileName": "",   //todo
                            "updateDate": updateDateTime
                        ]) { error in
                            if let error = error {
                                print("ユーザ情報の変更失敗(users collection): \(error)")
                                // Firestoreの更新が失敗した場合、emailを元に戻す(ロールバック)
                                if let currentEmail = currentEmail {
                                    Auth.auth().currentUser?.updateEmail(to: currentEmail) { rollbackError in
                                        if let rollbackError = rollbackError {
                                            print("Authロールバック失敗: \(rollbackError)")
                                        } else {
                                            print("Authロールバック成功")
                                        }
                                    }
                                }
                                continuation.resume(throwing: error)

                            } else {
                                //ユーザ情報更新成功時

                                //ログイン情報を更新
                                AppLoginUserInfo.email = email
                                AppLoginUserInfo.userName = userName
                                AppLoginUserInfo.gender = gender
                                AppLoginUserInfo.age = age
                                AppLoginUserInfo.residence = residence
                                AppLoginUserInfo.introduction = introduction
                                AppLoginUserInfo.profileImageFileName = ""   //todo
                                AppLoginUserInfo.updateDate = updateDateTime

                                continuation.resume(returning: true)
                            }
                        }
                    }
                }

            }
        }

    }
}

//プレビュー表示
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

