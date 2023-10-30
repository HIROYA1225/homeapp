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
    var body: some View {
        NavigationStack(path: $path){
            VStack(){
                //==================================
                //                // todo あとで削除　強制ログアウトボタン
                //                Button(action: {
                //                    do {
                //                        try logout()
                //                        print("ログアウトしました")
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
                                self.returnErrorMessage = handleFirebaseAuthLoginError(error)
                                //todo アラート アラートエラーメッセージ表示お願い(returnErrorMessageを表示させて)

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
                                if email.isEmpty || password.isEmpty {
                                    // todo アラート表示お願い("メールアドレスとパスワードを入力してください"のような)

                                    return
                                }
                                // ログイン処理
                                if try await emailLogin(email: email, password: password) {
                                    // メールアドレス確認チェック
                                    if AppLoginUserInfo.isMailConfirm {
                                        // ユーザ名登録チェック
                                        if try await checkDocumentExists() {
                                            // ユーザ情報を取得
                                            if try await getLoginUserInfo() {

                                                // トップ画面へ遷移
                                                // path.append("toLoginCheck")
                                                path.append("toProfile")
                                                //todo awaitさせないと画面表示早くなるかも
                                                try await getProfileImage()
                                            }
                                        } else {
                                            //ユーザ名登録画面へ遷移
                                            path.append("toRegisterNameOnly")
                                        }
                                    }else {
                                        // メール未認証時はログアウトさせる
                                        try logout()
                                        // todo メールアドレスを確認してください。アラートの表示
                                        print("メールアドレスを確認してください")
                                    }
                                }
                            } catch {
                                // 認証に失敗した場合のエラー処理
                                self.returnErrorMessage = handleFirebaseAuthLoginError(error)
                                //todo アラート アラートエラーメッセージ表示お願い(returnErrorMessageを表示させて)


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

                //成功時
                if user.email != nil {
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
        AppLoginUserInfo.email = user.email!
        AppLoginUserInfo.isLoggedIn = true
        AppLoginUserInfo.isMailConfirm = user.isEmailVerified
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
            print("ログアウトエラー: %@", signOutError)
        }
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



// todo ユーザ名登録画面(仮)
struct RegisterNameOnlyView: View {
    @State private var userName: String = ""
    @State private var returnMessage: String = ""

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
                        // 未入力チェック
                        if userName.isEmpty {
                            // todo アラート表示お願い
                            self.returnMessage = "ユーザ名がを入力してください。"
                            print(self.returnMessage)
                            return
                        }
                        //ユーザ名登録重複チェック(画面フィードバック用)
                        let isUnique = try await isUserNameUnique(userName)
                        if !isUnique {
                            // todo アラート表示
                            self.returnMessage = "ユーザ名が重複しています。"
                            return
                        }
                        // ユーザ名登録処理
                        let result = try await registerNameOnly()
                        if result {
                            // todo アラート表示お願い & トップ画面に遷移
                            self.returnMessage = "登録が完了しました。"
                            // トップ画面に遷移
                            // path.append("toLoginCheck")

                        } else {
                            // todo アラート表示お願い
                            self.returnMessage = "ユーザ名登録でエラーが発生しました。"

                        }
                    } catch {
                        // todo アラート表示お願い
                        self.returnMessage = "ユーザ名登録でエラーが発生しました。"
                    }
                }
            }
        }
        .padding()
    }

    // ユーザ情報登録(ユーザ名only)
    private func registerNameOnly() async throws -> Bool {

        // Firebase設定
        let db = Firestore.firestore()
        // ドキュメントIDはユーザuid
        let usersDocRef = db.collection(FirestoreCollections.users).document(AppLoginUserInfo.userUid)
        // ドキュメントIDは入力されたユーザ名
        let checkUserUniqueDocRef = db.collection(FirestoreCollections.checkUserUnique).document(userName)

        // 登録日付
        let currentDate = Timestamp(date: Date())

        //ユーザ情報の登録用
        let userData: [String: Any] = [
            FirestoreFields.Users.userName: userName,
            FirestoreFields.Users.createDate: currentDate,
            FirestoreFields.Users.updateDate: currentDate
        ]

        // ユーザ名重複チェック用(フィールド名はなんでもいい)
        let checkUniqueUserData: [String: Any] = [
            FirestoreFields.CheckUniqueUser.dummy: "",
        ]

        return try await withCheckedThrowingContinuation { continuation in
            // トランザクション処理
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                // ユニークチェックコレクションにデータをセット(すでに登録があればエラー返す)
                transaction.setData(checkUniqueUserData, forDocument: checkUserUniqueDocRef)
                // ユーザコレクションへデータをセット
                transaction.setData(userData, forDocument: usersDocRef)
                return true

            }) { (object, error) in
                if let error = error {
                    // 失敗時
                    continuation.resume(throwing: error)
                } else {
                    // 成功時
                    continuation.resume(returning: true)
                }
            }
        }

    }

    // ユーザ名ユニークチェック
    // 戻り値(すでに存在していればFalse 登録がなければTrue)
    private func isUserNameUnique(_ userName: String) async throws -> Bool {
        let db = Firestore.firestore()
        let checkUserUniqueDocRef = db.collection(FirestoreCollections.checkUserUnique).document(userName)
        let docSnapshot = try await checkUserUniqueDocRef.getDocument()
        return !docSnapshot.exists
    }

}
