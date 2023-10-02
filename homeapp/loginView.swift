//
//  loginView.swift
//  homeapp
//
//  Created by HIRO on 2023/08/22.
//

import SwiftUI
import FirebaseAuth
import Firebase
import GoogleSignIn

struct loginView: View {
    @State private var email = ""
    @State private var password = ""
    @State var path = NavigationPath()
    //ログイン情報
    @EnvironmentObject var AppLoginUserInfo: LoginUserInfo
    var body: some View {
        NavigationStack(path: $path){
            VStack(){
                //==================================
                // todo あとで削除　強制ログアウトボタン
                Button(action: {
                    do {
                        try logout()
                    } catch {
                        print("Failed to sign out")
                    }
                }){
                    Text("テスト用ログアウトボタン")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(15.0)
                }
                //==================================
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
                    Button(action:{
                        Task {
                            do {
                                //Google認証
                                try await googleAuth()

                                //ユーザ情報取得
                                let success = try await fetchUserInfo(uid: AppLoginUserInfo.userUid)
                                if success {
                                    //todoshi ユーザ情報取得成功時
                                    path.append("toLoginCheck")
                                } else {
                                    // todoshi エラー処理方法(ログイン情報あるが、名前未設定状態であると思われるため、名前入力画面に遷移させるか)
                                }
                            } catch {
                                // 認証に失敗した場合のエラー処理
                            }

                        }
                    }){
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
                        Task {
                            //ログイン処理
                            do {
                                try await Auth.auth().signIn(withEmail: email, password: password)

                                if let user = Auth.auth().currentUser {
                                    let uid = user.uid
                                    AppLoginUserInfo.userUid = uid
                                    AppLoginUserInfo.email = email

                                    //ログインフラグ
                                    AppLoginUserInfo.isLoggedIn = true

                                    //ユーザ情報取得
                                    let success = try await fetchUserInfo(uid: uid)
                                    if success {
                                        path.append("toLoginCheck")

                                    } else {
                                        // todoshi エラー処理方法(ログイン情報あるが、名前未設定状態であると思われるため、名前入力画面に遷移させるか)
                                    }
                                }
                            } catch {
                                // エラー処理
                                if let errorCode = AuthErrorCode.Code(rawValue: (error as NSError).code) {
                                    // エラーコードに応じた処理
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

    //Google認証用のサインアップ
    func googleAuth() async throws {

        guard let clientID: String = FirebaseApp.app()?.options.clientID else { throw AuthError.clientIDNotFound }
        let config: GIDConfiguration = GIDConfiguration(clientID: clientID)

        let windowScene: UIWindowScene? = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController: UIViewController? = windowScene?.windows.first?.rootViewController

        GIDSignIn.sharedInstance.configuration = config

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController!)

        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.invalidUserOrToken
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

        //Googleログイン
        try await googleLogin(credential: credential)
    }

    //Google認証用のログイン
    func googleLogin(credential: AuthCredential) async throws {

        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let user = authResult?.user else {
                    continuation.resume(throwing: AuthError.customError("User not found"))
                    return
                }

                //成功時
                if let email = user.email {
                    AppLoginUserInfo.userUid = authResult!.user.uid
                    AppLoginUserInfo.email = email
                    AppLoginUserInfo.isLoggedIn = true
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: AuthError.customError("エラー発生"))
                    return
                }
            }
        }
    }

    //Google認証用
    enum AuthError: Error {
        case clientIDNotFound
        case invalidUserOrToken
        case customError(String)
    }
    enum SignInError: Error {
        case customError(String)
    }


    //ユーザ情報取得(user collection)
    func fetchUserInfo(uid: String) async throws -> Bool  {
        let db = Firestore.firestore()
        let docRef = db.collection(FirestoreCollections.users).document(uid)

        return try await withCheckedThrowingContinuation { continuation in
            docRef.getDocument { (document, error) in
                if let document = document, document.exists, let data = document.data() {
                    AppLoginUserInfo.userEmail = data[FirestoreFields.Users.userEmail] as? String ?? ""
                    AppLoginUserInfo.userName = data[FirestoreFields.Users.userName] as? String ?? ""
                    AppLoginUserInfo.gender = data[FirestoreFields.Users.gender] as? String ?? ""
                    AppLoginUserInfo.age = data[FirestoreFields.Users.age] as? String ?? ""
                    AppLoginUserInfo.residence = data[FirestoreFields.Users.residence] as? String ?? ""
                    AppLoginUserInfo.introduction = data[FirestoreFields.Users.introduction] as? String ?? ""
                    AppLoginUserInfo.profileImageFileName = data[FirestoreFields.Users.profileImageFileName] as? String ?? ""
                    AppLoginUserInfo.createDate = data[FirestoreFields.Users.createDate] as? String ?? ""
                    AppLoginUserInfo.updateDate = data[FirestoreFields.Users.updateDate] as? String ?? ""

                    continuation.resume(returning: true)
                }else {
                    print("ドキュメントが存在しないか、ドキュメントの取得中にエラーが発生しました: \(error?.localizedDescription ?? "エラーの詳細なし")")
                    continuation.resume(throwing: NSError(domain: "", code: 0, userInfo: nil))
                }
            }
        }
    }

    //ログアウト
    func logout() throws {
        do {
            //ログアウト
            try Auth.auth().signOut()

            // 状態リセット
            AppLoginUserInfo.isLoading = false
            AppLoginUserInfo.isRegisterAuth = false
            AppLoginUserInfo.isMailConfirm = false
            AppLoginUserInfo.isRegisterName = false
            AppLoginUserInfo.isLoggedIn = false

            AppLoginUserInfo.userUid = ""
            AppLoginUserInfo.email = ""

            AppLoginUserInfo.userEmail = ""
            AppLoginUserInfo.userName = ""
            AppLoginUserInfo.gender = ""
            AppLoginUserInfo.age = ""
            AppLoginUserInfo.residence = ""
            AppLoginUserInfo.introduction = ""
            AppLoginUserInfo.profileImageFileName = ""
            AppLoginUserInfo.createDate = ""
            AppLoginUserInfo.updateDate = ""

        } catch let signOutError as NSError {
            print("ログアウトエラー: %@", signOutError)
        }
    }

}

struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        loginView()
    }
}



