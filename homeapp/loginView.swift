//
//  loginView.swift
//  homeapp
//
//  Created by HIRO on 2023/08/22.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct loginView: View {
    @State private var email = ""
    @State private var password = ""
    @State var path = NavigationPath()
    //ログイン情報
    @EnvironmentObject var AppLoginUserInfo: LoginUserInfo
    var body: some View {
        NavigationStack(path: $path){
            VStack(){
                Text("褒めアプテスト")
                    .font(.largeTitle).foregroundColor(Color.black)
                    .padding([.top, .bottom], 40)
                TextField("Email", text:self.$email)
                    .padding()
                    .cornerRadius(20.0)
                    .autocapitalization(.none)
                SecureField("Password", text:self.$password)
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
                .padding(.bottom,20)
                .offset(x:-5)
                HStack(){
                    Button(action:{
                        //ログイン処理
                        Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
                            if error == nil {
                                //サインイン成功(非同期)
                                DispatchQueue.main.async {
                                    if let email = authResult!.user.email {
                                        let uid = authResult!.user.uid
                                        AppLoginUserInfo.userUid = uid
                                        AppLoginUserInfo.email = email

                                        //ログインフラグ
                                        AppLoginUserInfo.isLoggedIn = true

                                        let db = Firestore.firestore()
                                        let docRef = db.collection("users").document(uid)

                                        docRef.getDocument { (document, error) in
                                            if let document = document, document.exists, let data = document.data() {
                                                AppLoginUserInfo.userEmail = data["userEmail"] as? String ?? ""
                                                AppLoginUserInfo.userName = data["userName"] as? String ?? ""
                                                AppLoginUserInfo.gender = data["gender"] as? String ?? ""
                                                AppLoginUserInfo.age = data["age"] as? String ?? ""
                                                AppLoginUserInfo.residence = data["residence"] as? String ?? ""
                                                AppLoginUserInfo.introduction = data["introduction"] as? String ?? ""
                                                AppLoginUserInfo.profileImageFileName = data["profileImageFileName"] as? String ?? ""
                                                AppLoginUserInfo.createDate = data["createDate"] as? String ?? ""
                                                AppLoginUserInfo.updateDate = data["updateDate"] as? String ?? ""

                                                path.append("toLoginCheck")
                                            } else {

                                                //todoshi エラー処理方法(ログイン情報あるが、名前未設定状態であると思われるため、名前入力画面に遷移させるか)
                                                print("ドキュメントが存在しないか、ドキュメントの取得中にエラーが発生しました: \(error?.localizedDescription ?? "エラーの詳細なし")")
                                            }
                                        }
                                    }
                                }
                            } else {
                                let errorCode = AuthErrorCode.Code(rawValue: error!._code)
                                switch errorCode {
                                case .invalidEmail:
                                    //todoshi エラー処理方法
                                    print("入力されたメールアドレスの形式が正しくありません。")
                                case .weakPassword:
                                    print("パスワードが弱すぎます。6文字以上の強固なものを設定してください。")
                                case .wrongPassword:
                                    print("入力されたパスワードが間違っています。")
                                case .userNotFound:
                                    print("入力されたメールアドレスのユーザーは登録されていません。")
                                case .networkError:
                                    print("通信エラーが発生しました。ネットワークの状態を確認してください。")
                                default:
                                    print("予期しないエラーが発生しました。再度お試しいただくか、サポートへお問い合わせください。")
                                }
                            }
                        }
                    }){
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15.0)
                    }
                    Button(action:{
                        path.append("toRegister")
                    }){
                        Text("新規登録")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15.0)
                    }

                }
            }
            .navigationDestination(for:String.self){ destination in
                switch destination {
                case "toLoginCheck":
                    homeView()
                case "toRegister":
                    registerView()
                default:
                    loginView()
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
