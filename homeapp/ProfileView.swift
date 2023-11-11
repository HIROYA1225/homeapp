//
//  ProfileView.swift
//  homeapp
//
//  Created by Yosuke on 2023/09/20.
//

import UIKit
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

struct ProfileView: View {
    @State private var email = ""

    @State private var userName = ""    //ユーザー名
    @State private var gender = ""  //性別
    @State private var age = ""     //年齢
    @State private var residence = ""   //住所
    @State private var introduction = ""    //紹介文

    @State private var profileImageFileName = ""    //プロフィール画像ファイル名
    @State private var profileImage: Image?
    
    //画像選択 定義
    @State private var image: UIImage?
    @State var showingImagePicker = false

    //ログイン情報
    @EnvironmentObject var AppLoginUserInfo: LoginUserInfo

    //リスト 定義
    let prefectures = ["北海道", "青森県", "岩手県", "宮城県", "秋田県",
                       "山形県", "福島県", "茨城県", "栃木県", "群馬県",
                       "埼玉県", "千葉県", "東京都", "神奈川県","新潟県",
                       "富山県", "石川県", "福井県", "山梨県", "長野県",
                       "岐阜県", "静岡県", "愛知県", "三重県", "滋賀県",
                       "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県",
                       "鳥取県", "島根県", "岡山県", "広島県", "山口県",
                       "徳島県", "香川県", "愛媛県", "高知県", "福岡県",
                       "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県",
                       "鹿児島県", "沖縄県"]   //都道府県
    let genders = ["男性", "女性", "その他"]   //性別
    
    //幅 定義
    private let recWidth:CGFloat = 120     //下線幅
    private let recHeight:CGFloat = 1.5     //下線高さ
    private let itemWidth:CGFloat = 92     //項目幅
    private let itemHeight:CGFloat = 15     //項目高さ
    private let imageWidth:CGFloat = 120   //画像
    private let introWidth:CGFloat = 220   //画像
    
    //画面触ったらキーボード閉じる処理の準備
    enum Field: Hashable {
        case userName
        case age
        case introduction
    }
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing:30){
            //プロフィール画像
            ZStack {
                //初期画像
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageWidth, height: imageWidth)
                    .foregroundColor(.black)
                
                //画像選択処理
                if let uiImage = image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: imageWidth, height: imageWidth)
                        .clipShape(Circle())
                } else {
                    Image("noimage")
                        .resizable()
                        .frame(width: imageWidth, height: imageWidth)
                        .clipShape(Circle())
                }
                
                //プロフィール画像ボタン
                Button(action: {
                    showingImagePicker = true   //画像選択画面表示
                }){
                    Image("noimage")
                        .resizable()
                        .frame(width: imageWidth, height: imageWidth)
                        .clipShape(Circle())
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
            }
            
            //名前
            HStack{
                    Text("Name")    //項目"Name"
                        .frame(width: itemWidth, height: itemHeight, alignment:.leading)
                VStack{
                    TextField("", text:self.$userName)
                        .keyboardType(.default)
                        .frame(width: recWidth, height: itemHeight)
                        //画面触ったらキーボード閉じる処理
                        .focused($focusedField, equals: .userName)
                        .onTapGesture {
                           focusedField = .userName
                        }
                    Rectangle()
                        .frame(width: recWidth,height: recHeight)
                        .foregroundColor(.black)
                }
            }
            
            HStack{
                Text("Gender")
                    .frame(width: itemWidth, height: itemHeight, alignment:.leading)
                VStack{
                    Picker("", selection: self.$gender) {
                        ForEach(genders, id: \.self) { item in
                            Text(item)
                        }
                    }
                    .frame(width: recWidth, height: itemHeight, alignment:.leading)
                    Rectangle()
                        .frame(width: recWidth,height: recHeight).foregroundColor(.black)
                }
            }
            
            HStack{
                Text("Age")
                    .frame(width: itemWidth, height: itemHeight, alignment:.leading)
                VStack{
                    TextField("", text:self.$age)
                        .keyboardType(.numberPad)
                        .frame(width: recWidth, height: itemHeight)
                        //画面触ったらキーボード閉じる処理
                        .focused($focusedField, equals: .age)
                        .onTapGesture {
                           focusedField = .age
                        }
                    Rectangle()
                        .frame(width: recWidth,height: recHeight).foregroundColor(.black)
                }
            }
            
            HStack{
                Text("Location")
                    .frame(width: itemWidth, height: itemHeight, alignment:.leading)
                VStack{
                    Picker("", selection: self.$residence) {
                        ForEach(prefectures, id: \.self) { item in
                            Text(item)
                        }
                    }
                    .frame(width: recWidth, height: itemHeight, alignment:.leading)
                    Rectangle()
                        .frame(width: recWidth,height: recHeight).foregroundColor(.black)
                }
            }

            VStack{
                Text("About")
                    .frame(width: introWidth, height: itemHeight, alignment:.leading)
                TextEditor(text:self.$introduction)
                    .keyboardType(.default)
                    .frame(width: introWidth,height: 150,alignment: .topLeading)
                    .border(Color.black,width: 1)
                    //画面触ったらキーボード閉じる処理
                    .focused($focusedField, equals: .introduction)
                    .onTapGesture {
                       focusedField = .introduction
                    }
            }
            
            //決定ボタン
            HStack(){
                Button(action:{
                    Task {
                        do {
                            //todo test用==
                            email = AppLoginUserInfo.email
                            //==

//                            //ユーザ情報変更
//                            let success = try await updateUser(email: email, userName: userName, gender: gender, age: age, residence: residence, introduction: introduction)
//                            if success {
//                                print("成功")
//                            } else {
//
//                            }
                        }
                    }
                }){
                    Text("決定")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(20.0)
                }
            }
        }
        //    画面触ったらキーボード閉じる処理
        .onTapGesture {
            focusedField = nil
        }

//        .onAppear() {
//            //ログインユーザ情報取得
//            getLoginUserInfo()
//        }
    }

//    //ログインユーザ情報取得
//    private func getLoginUserInfo() {
//
//        //ユーザコレクション情報の取得
//        self.email = AppLoginUserInfo.email
//        self.userName = AppLoginUserInfo.userName
//        self.gender = AppLoginUserInfo.gender
//        self.age = AppLoginUserInfo.age
//        self.residence = AppLoginUserInfo.residence
//        self.introduction = AppLoginUserInfo.introduction
//        self.profileImageFileName = AppLoginUserInfo.profileImageFileName
//
//        //プロフィール画像の取得
//        self.profileImage = AppLoginUserInfo.profileImage
//    }

//    //ユーザ情報変更
//    // todo プロフィール画像の更新
//    private func updateUser(email: String, userName: String, gender: String, age: String, residence: String, introduction: String) async throws -> Bool {
//
//        return try await withCheckedThrowingContinuation { continuation in
//
//            // 現在のemailを保持(ロールバック用)
//            let currentEmail = Auth.auth().currentUser?.email
//
//            //更新日時
//            let currentDateTime = Date()
//            let updateDateTime: Timestamp = Timestamp(date: currentDateTime)
//
//            Auth.auth().currentUser?.updateEmail(to: email) { error in
//                if let error = error {
//                    print("ユーザ情報の変更失敗(Auth): \(error)")
//                    continuation.resume(throwing: error)
//                } else {
//                    print("ユーザ情報の変更成功(Auth)")
//                    // UIDを取得してFirestoreで他の情報を更新
//                    if let uid = Auth.auth().currentUser?.uid {
//                        let db = Firestore.firestore()
//                        db.collection("users").document(uid).updateData([
//                            "userName": userName,
//                            "gender": gender,
//                            "age": age,
//                            "residence": residence,
//                            "introduction": introduction,
//                            "profileImgFileName": "",   //todo
//                            "updateDate": updateDateTime
//                        ]) { error in
//                            if let error = error {
//                                print("ユーザ情報の変更失敗(users collection): \(error)")
//                                // Firestoreの更新が失敗した場合、emailを元に戻す(ロールバック)
//                                if let currentEmail = currentEmail {
//                                    Auth.auth().currentUser?.updateEmail(to: currentEmail) { rollbackError in
//                                        if let rollbackError = rollbackError {
//                                            print("Authロールバック失敗: \(rollbackError)")
//                                        } else {
//                                            print("Authロールバック成功")
//                                        }
//                                    }
//                                }
//                                continuation.resume(throwing: error)
//
//                            } else {
//                                //ユーザ情報更新成功時
//
//                                //ログイン情報を更新
//                                AppLoginUserInfo.email = email
//                                AppLoginUserInfo.userName = userName
//                                AppLoginUserInfo.gender = gender
//                                AppLoginUserInfo.age = age
//                                AppLoginUserInfo.residence = residence
//                                AppLoginUserInfo.introduction = introduction
//                                AppLoginUserInfo.profileImageFileName = ""   //todo
//                                AppLoginUserInfo.updateDate = updateDateTime
//
//                                continuation.resume(returning: true)
//                            }
//                        }
//                    }
//                }
//
//            }
//        }
//
//        }
//    }
}

//画像選択ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

//プレビュー表示
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

