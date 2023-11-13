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
import FirebaseStorage

struct loginView: View {
    @State private var email = ""
    @State private var password = ""
    @State var path = NavigationPath()
    @State private var returnErrorMessage = ""
    //ログイン情報
    @EnvironmentObject var AppLoginUserInfo: LoginUserInfo
    // Firebaseの状態を確認するための状態変数
    @State private var viewSelector: Int? = nil

    var body: some View {
        NavigationStack(path: $path){
            VStack(){

                //==================================
//                // todo あとで削除　強制ログアウトボタン
//                Button(action: {
//                    do {
//                        if try logout(AppLoginUserInfo: AppLoginUserInfo) {
//                            print("ログアウト成功")
//                        }
//                    } catch {
//                        print("Failed to sign out")
//                    }
//                }){
//                    Text("テスト用ログアウトボタン")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.red)
//                        .cornerRadius(15.0)
//                }
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
                        // インスタンス化させる必要あり
                        let loginChecker = LoginStatusChecker()
                        Task {
                            do {
                                //Google認証(メールアドレス確認不要)
                                try await googleAuth()
                                // ログインユーザ状態チェック
                                viewSelector = try await loginChecker.checkLoginStatus()
                                switch viewSelector {
                                case 2:
                                    //ユーザ名登録画面へ遷移
                                    path.append("toRegisterNameOnly")
                                case 3:
                                    // トップ画面へ遷移
//                                    path.append("toLoginCheck")
                                    path.append("toProfile")
                                default:
                                    // ログイン画面へ
                                    path.append("loginView")
                                }
                            } catch {
                                // 認証に失敗した場合のエラー処理
                                self.returnErrorMessage = handleFirebaseAuthLoginError(error)
                                //todo アラート アラートエラーメッセージ表示お願い(returnErrorMessageを表示させて)

                                // todo  デバッグ用
                                print("Googleログインエラー")
                                print(error)

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
                        // インスタンス化させる必要あり
                        let loginChecker = LoginStatusChecker()
                        Task {
                            do {
                                if email.isEmpty || password.isEmpty {
                                    // todo アラート表示お願い("メールアドレスとパスワードを入力してください"のような)

                                    return
                                }
                                // ログイン処理
                                if try await emailLogin(email: email, password: password) {
                                    // ログインユーザ状態チェック
                                    viewSelector = try await loginChecker.checkLoginStatus()
                                    switch viewSelector {
                                    case 1:
                                        // Email確認してください画面へ遷移
                                        path.append("iraiEmailConfirmView")
                                    case 2:
                                        //ユーザ名登録画面へ遷移
                                        path.append("toRegisterNameOnly")
                                    case 3:
                                        // トップ画面へ遷移
//                                        path.append("toLoginCheck")
                                        path.append("toProfile")
                                    default:
                                        // ログイン画面へ
                                        path.append("loginView")
                                    }
                                }
                            } catch {
                                // 認証に失敗した場合のエラー処理
                                self.returnErrorMessage = handleFirebaseAuthLoginError(error)
                                //todo アラート アラートエラーメッセージ表示お願い(returnErrorMessageを表示させて)

                                // todo デバッグ用
                                print("emailログインエラー")
                                print(error)
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
                case "toRegisterNameOnly":
                    RegisterNameOnlyView()
                case "LoadingView":
                    LoadingView()
                case "iraiEmailConfirmView":
                    iraiEmailConfirmView()
                    //todo test用=======
                case "toProfile":
                    ProfileView()
                    //==================
                default:
                    loginView()
                }
            }
        }
    }

    //Email認証用のログイン
    private func emailLogin(email: String,password: String) async throws -> Bool {

        return try await withCheckedThrowingContinuation { continuation in

            Auth.auth().signIn(withEmail: email, password: password){ (authResult, error) in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                if let user = Auth.auth().currentUser {
                    loginSuccessUpdateUserInfo(user:user)
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: 0, userInfo: nil))
                }
            }
        }
    }

    //Google認証用のサインアップ
    private func googleAuth() async throws {

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
    private func googleLogin(credential: AuthCredential) async throws {

        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(with: credential) { authResult, error in
                //ログインエラー時
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let user = authResult?.user else {
                    continuation.resume(throwing: AuthError.customError("ユーザが見つかりません"))
                    return
                }
                if user.email != nil {
                    //成功時
                    loginSuccessUpdateUserInfo(user:user)
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: AuthError.customError("メールアドレスが見つかりません"))
                    return
                }
            }
        }
    }

    //ログイン成功時、LoginUserInfoを更新
    private func loginSuccessUpdateUserInfo(user: User) {
            AppLoginUserInfo.userUid = user.uid
            AppLoginUserInfo.email = user.email ?? ""

    }
    private enum AuthError: Error {
        case clientIDNotFound
        case invalidUserOrToken
        case customError(String)
    }
    private enum SignInError: Error {
        case customError(String)
    }

    //FirebaserAUthエラー
    private func handleFirebaseAuthLoginError(_ error: Error) -> String {
        var returnMessage = ""
        if let errorCode = AuthErrorCode.Code(rawValue: (error as NSError).code) {
            switch errorCode {
            case .wrongPassword:
                returnMessage = "入力されたパスワードが間違っています。"
            case .userNotFound:
                returnMessage = "入力されたメールアドレスのユーザーは登録されていません。"
            case .networkError:
                returnMessage = "通信エラーが発生しました。ネットワークの状態を確認してください。"
            default:
                returnMessage = "ログイン時にエラーが発生しました。アプリを閉じて再度お試しください。"
            }
        }
        return returnMessage
    }
}

struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        loginView()
    }
}

