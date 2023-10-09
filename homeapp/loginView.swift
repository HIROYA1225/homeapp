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
    //ログイン情報
    @EnvironmentObject var AppLoginUserInfo: LoginUserInfo
    var body: some View {
        NavigationStack(path: $path){
            VStack(){
                //==================================
//                                // todo あとで削除　強制ログアウトボタン
//                                Button(action: {
//                                    do {
//                                        try logout()
//                                        print("ログアウトしました")
//                                    } catch {
//                                        print("Failed to sign out")
//                                    }
//                                }){
//                                    Text("テスト用ログアウトボタン")
//                                        .font(.headline)
//                                        .foregroundColor(.white)
//                                        .padding()
//                                        .background(Color.red)
//                                        .cornerRadius(15.0)
//                                }
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
                                //Google認証(メールアドレス確認不要)
                                try await googleAuth()
                                // ユーザ名登録チェック
                                if try await checkDocumentExists() {
                                    //ユーザ情報取得
                                    if try await getLoginUserInfo() {
                                        // トップ画面へ遷移
                                        path.append("toLoginCheck")
                                        //todo awaitさせないと画面表示早くなるかも
                                        try await getProfileImage()
                                    }
                                } else {
                                    //ユーザ名登録画面へ遷移
                                    path.append("toRegisterNameOnly")
                                }
                            } catch {
                                // 認証に失敗した場合のエラー処理
                                handleAuthError(error)
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
                            do {
                                // ログイン処理
                                if try await emailLogin(email: email, password: password) {
                                    // メールアドレス確認チェック
                                    if AppLoginUserInfo.isMailConfirm {
                                        // ユーザ名登録チェック
                                        if try await checkDocumentExists() {
                                            // ユーザ情報を取得
                                            if try await getLoginUserInfo() {
                                                // トップ画面へ遷移
//                                                path.append("toLoginCheck")
                                                path.append("toProfile")
                                                //todo awaitさせないと画面表示早くなるかも
                                                try await getProfileImage()
                                            }
                                        } else {
                                            //ユーザ名登録画面へ遷移
                                            path.append("toRegisterNameOnly")
                                        }
                                    }else {
                                        // todo メールアドレスを確認してください。アラートの表示
                                        print("メールアドレスを確認してください")
                                    }

                                }
                            } catch {
                                // エラー処理
                                handleAuthError(error)
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
                case "toProfile":
                    ProfileView()
                default:
                    loginView()
                }
            }

        }
    }

    //Email認証用のログイン
    private func emailLogin(email: String,password: String) async throws -> Bool {

        return try await withCheckedThrowingContinuation { continuation in

            Auth.auth().signIn(withEmail: email, password: password)

            if let user = Auth.auth().currentUser {
                AppLoginUserInfo.userUid = user.uid
                AppLoginUserInfo.email = email

                //ログインフラグ
                AppLoginUserInfo.isLoggedIn = true
                AppLoginUserInfo.isMailConfirm = user.isEmailVerified

                continuation.resume(returning: true)
            } else {
                continuation.resume(throwing: NSError(domain: "", code: 0, userInfo: nil))
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
                    AppLoginUserInfo.userUid = user.uid
                    AppLoginUserInfo.email = email
                    AppLoginUserInfo.isLoggedIn = true
                    AppLoginUserInfo.isMailConfirm = user.isEmailVerified
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: AuthError.customError("エラー発生"))
                    return
                }
            }
        }
    }

    //Google認証用
    private enum AuthError: Error {
        case clientIDNotFound
        case invalidUserOrToken
        case customError(String)
    }
    private enum SignInError: Error {
        case customError(String)
    }

    // ドキュメントIDが存在するかチェック
    private func checkDocumentExists() async throws -> Bool {
        let db = Firestore.firestore()
        let docRef = db.collection(FirestoreCollections.users).document(AppLoginUserInfo.userUid)

        let docSnapshot = try await docRef.getDocument()
        return docSnapshot.exists
    }

    //ユーザ情報取得
    private func getLoginUserInfo() async throws -> Bool  {
        let db = Firestore.firestore()
        let docRef = db.collection(FirestoreCollections.users).document(AppLoginUserInfo.userUid)

        return try await withCheckedThrowingContinuation { continuation in
            docRef.getDocument { (document, error) in
                if let document = document, document.exists, let data = document.data() {
                    AppLoginUserInfo.userName = data[FirestoreFields.Users.userName] as? String ?? ""
                    AppLoginUserInfo.gender = data[FirestoreFields.Users.gender] as? String ?? ""
                    AppLoginUserInfo.age = data[FirestoreFields.Users.age] as? String ?? ""
                    AppLoginUserInfo.residence = data[FirestoreFields.Users.residence] as? String ?? ""
                    AppLoginUserInfo.introduction = data[FirestoreFields.Users.introduction] as? String ?? ""
                    AppLoginUserInfo.profileImageFileName = data[FirestoreFields.Users.profileImageFileName] as? String ?? ""
                    AppLoginUserInfo.createDate = data[FirestoreFields.Users.createDate] as? Timestamp ?? nil
                    AppLoginUserInfo.updateDate = data[FirestoreFields.Users.updateDate] as? Timestamp ?? nil

                    continuation.resume(returning: true)
                }else {
                    print("ドキュメントの取得中にエラーが発生しました: \(error?.localizedDescription ?? "エラーの詳細なし")")
                    continuation.resume(throwing: NSError(domain: "", code: 0, userInfo: nil))
                }
            }
        }
    }

    //プロフィール画像取得処理
    private func getProfileImage() async throws -> Void {

        //uiImageとImage型変換用
        var uiImageProf: UIImage?

        //デフォルト画像
        AppLoginUserInfo.profileImage = Image(AppImageName.ProfileImageNoSet_icon)

        //登録画像がある場合、
        let profileImageFileName = AppLoginUserInfo.profileImageFileName
        if !profileImageFileName.isEmpty {
            //画像パス作成
            let imgDir = URL(string: FirebaseStorage.profileImageDirName)!
            let imgDirWithSubfolder = imgDir.appendingPathComponent(AppLoginUserInfo.userUid)
            let proImgFullPath = imgDirWithSubfolder.appendingPathComponent(profileImageFileName).absoluteString

            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imagesRef = storageRef.child(proImgFullPath)

            // FirebaseStrageよりプロフィール画像を取得する
            imagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("登録プロフィール画像取得失敗: \(error)")
                } else if let data = data {
                    uiImageProf = UIImage(data: data)
                    AppLoginUserInfo.profileImage = Image(uiImage: uiImageProf!)
                }
            }
        }
    }


    //ログインエラー
    private func handleAuthError(_ error: Error) {
        if let errorCode = AuthErrorCode.Code(rawValue: (error as NSError).code) {
            // todo エラーコードに応じた処理
            switch errorCode {
            case .invalidEmail:
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

    //ログアウト
    private func logout() throws {
        do {
            //ログアウト
            try Auth.auth().signOut()

            // 状態リセット
            AppLoginUserInfo.isRegisterAuth = false
            AppLoginUserInfo.isMailConfirm = false
            AppLoginUserInfo.isRegisterName = false
            AppLoginUserInfo.isLoggedIn = false

            AppLoginUserInfo.userUid = ""
            AppLoginUserInfo.email = ""

            AppLoginUserInfo.userName = ""
            AppLoginUserInfo.gender = ""
            AppLoginUserInfo.age = ""
            AppLoginUserInfo.residence = ""
            AppLoginUserInfo.introduction = ""
            AppLoginUserInfo.profileImageFileName = ""
            AppLoginUserInfo.createDate = nil
            AppLoginUserInfo.updateDate = nil

        } catch let signOutError as NSError {
            // todo
            print("ログアウトエラー: %@", signOutError)
        }
    }

}

struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        loginView()
    }
}



// todo ユーザ名登録画面(仮)
struct RegisterNameOnlyView: View {
    @State private var userName: String = ""

    //ログイン情報
    @EnvironmentObject var AppLoginUserInfo: LoginUserInfo

    var body: some View {
        VStack {
            TextField("ユーザー名", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("登録") {
                Task {
                    do {
                        //ユーザ名登録重複チェック

                        // ユーザ名登録処理
                        let result = try await registerNameOnly()
                        if result {
                            // トップ画面に遷移
                            //path.append("toLoginCheck")
                        } else {
                            //ユーザ名登録エラー発生

                        }

                    } catch {
                        print("エラー: \(error)")
                    }
                }
            }
        }
        .padding()
    }

    // ユーザ情報登録(ユーザ名only)
    private func registerNameOnly()  async throws -> Bool  {
        let db = Firestore.firestore()
        let newDocRef = db.collection(FirestoreCollections.users).document(AppLoginUserInfo.userUid)

        let currentDate = Timestamp(date: Date())

        return try await withCheckedThrowingContinuation { continuation in
            newDocRef.setData([
                "userName": userName,
                "createDate": currentDate,
                "updateDate": currentDate
            ]) { error in
                if let error = error {
                    print("エラー: \(error)")
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }

}
