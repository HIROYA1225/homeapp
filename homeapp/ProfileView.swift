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
import FirebaseStorage

struct ProfileView: View {
    @State private var userName = ""
    @State private var gender = ""
    @State private var age = ""
    @State private var residence = ""
    @State private var introduction = ""
    @State private var profileImageFileName = ""

    @State private var returnMessage = ""

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
                       "鹿児島県", "沖縄県"]
    let genders = ["男性", "女性", "その他"]
    
    //幅 定義
    private let Rec_width:CGFloat = 120
    private let Item_width:CGFloat = 92
    private let Image_width:CGFloat = 120
    
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
                //初期画像(画像を登録していない場合)
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Image_width, height: Image_width)
                    .foregroundColor(.black)
                // 画像選択画面で選択した画像を表示
                if image != nil {
                    Image(uiImage: image!)
                        .resizable()
                        .frame(width: Image_width, height: Image_width)
                        .clipShape(Circle())
                // 初期画像(画像の登録をすでに行なっている場合)
                } else if  AppLoginUserInfo.profileImage != nil {
                    Image(uiImage: AppLoginUserInfo.profileImage!)
                        .resizable()
                        .frame(width: Image_width, height: Image_width)
                        .clipShape(Circle())
                }
                Button(action: {
                    showingImagePicker = true
                }){
                    //ボタンに重なるImageらしい、書かないとエラーになる。画像は透明にしているので、何をセットしてもいい。
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: Image_width, height: Image_width)
                        .clipShape(Circle())
                        .opacity(0)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
            }
            
            //名前
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
                            //ユーザ情報変更
                            if try await updateUser(userName: userName, gender: gender, age: age, residence: residence, introduction: introduction, image: image!) {
                                // todo ユーザ情報の更新が成功しました。というようなアラートを表示と画面遷移
                                self.returnMessage = "更新されました。"

                            } else {
                                // todo ユーザ情報の更新にエラーが発生しました。というようなアラートを表示
                                self.returnMessage = "ユーザ情報の更新にエラーが発生しました。"

                            }
                        } catch {
                            // todo ユーザ情報の更新にエラーが発生しました。というようなアラートを表示
                            print(error)
                            self.returnMessage = "ユーザ情報の更新にエラーが発生しました。"

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
            //初期画面表示用：ログインユーザ情報取得
            getLoginUserInfo()
        }
        //    画面触ったらキーボード閉じる処理
        .onTapGesture {
            focusedField = nil
        }
    }
    
    //ログインユーザ情報取得
    private func getLoginUserInfo() {
        //ユーザコレクション情報の取得
        self.userName = AppLoginUserInfo.userName
        self.gender = AppLoginUserInfo.gender
        self.age = AppLoginUserInfo.age
        self.residence = AppLoginUserInfo.residence
        self.introduction = AppLoginUserInfo.introduction
        self.profileImageFileName = AppLoginUserInfo.profileImageFileName
        //プロフィール画像の取得
        self.image = AppLoginUserInfo.profileImage
    }
    
    //ユーザ情報変更
    private func updateUser(userName: String, gender: String, age: String, residence: String, introduction: String, image: UIImage) async throws -> Bool {
        
        return try await withCheckedThrowingContinuation { continuation in
            //更新日時(Firestore用にTimestamp型に変換)
            let currentDateTime = Date()
            let updateDateTime: Timestamp = Timestamp(date: currentDateTime)

            // UIDを取得してFirestoreで他の情報を更新
            if let uid = Auth.auth().currentUser?.uid {
                let db = Firestore.firestore()
                let storageRef = Storage.storage().reference()
                // 保存先の設定(ファイル名は「uid + ".png"」にて保存)
                let profileImageRef = storageRef.child(FirebaseStorage.profileImageDirName + "/\(uid)/\(uid)" + FileExtension.PngFileEx)
                // 画像をアップロード
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    profileImageRef.putData(imageData, metadata: nil) { metadata, error in
                        if let error = error {
                            // 画像アップロード失敗時
                            continuation.resume(throwing: error)
                            return
                        }
                        // アップロード成功時、画像のURLを取得
                        profileImageRef.downloadURL { url, error in
                            if let error = error {
                                // URL取得失敗時
                                continuation.resume(throwing: error)
                                return
                            }

                            // 画像URLをStringに変換し、コレクションに登録
                            if let imageUrl = url?.absoluteString {
                                // Firestoreにユーザ情報を更新
                                db.collection(FirestoreCollections.users).document(uid).updateData([
                                    FirestoreFields.Users.userName: userName,
                                    FirestoreFields.Users.gender: gender,
                                    FirestoreFields.Users.age: age,
                                    FirestoreFields.Users.residence: residence,
                                    FirestoreFields.Users.introduction: introduction,
                                    FirestoreFields.Users.profileImageFileName: imageUrl,
                                    FirestoreFields.Users.updateDate: updateDateTime
                                ]) { error in
                                    if let error = error {
                                        // コレクション更新失敗時
                                        // 画像の更新をロールバック
                                        if let imageData = AppLoginUserInfo.profileImage?.jpegData(compressionQuality: 0.8) {
                                            profileImageRef.putData(imageData, metadata: nil) { metadata, error in
                                                if let error = error {
                                                    // 画像アップロード失敗時
                                                    continuation.resume(throwing: error)
                                                    return
                                                }
                                            }
                                        }
                                        continuation.resume(throwing: error)
                                    } else {
                                        // ユーザ情報更新成功時。ログイン情報を更新
                                        AppLoginUserInfo.userName = userName
                                        AppLoginUserInfo.gender = gender
                                        AppLoginUserInfo.age = age
                                        AppLoginUserInfo.residence = residence
                                        AppLoginUserInfo.introduction = introduction
                                        AppLoginUserInfo.profileImageFileName = imageUrl
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
        
    }
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
            
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
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

