import SwiftUI
import FirebaseAuth
import Firebase

//ユーザ情報取得
func getLoginUserInfo(AppLoginUserInfo: LoginUserInfo) async throws -> Bool  {
    // ユーザuid取得(ログインしていない場合は、falseを返す)
    guard let userUid = Auth.auth().currentUser?.uid else {
        return false
    }
    let db = Firestore.firestore()
    let docRef = db.collection(FirestoreCollections.users).document(userUid)

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

//プロフィール画像取得処理(画像URLから取得)
func getProfileImage(AppLoginUserInfo: LoginUserInfo) async throws -> UIImage? {

    // 画像URLを変数にセット
    let urlString = AppLoginUserInfo.profileImageFileName

    guard let url = URL(string: urlString) else {
        // 不正なURL
        throw CustomError.genericError("不正なURLです。")
    }
    // 画像URLを非同期にダウンロード
    let (data, response) = try await URLSession.shared.data(from: url)
    // responseのサーバエラーチェック(ステータスコードが200でない場合エラー)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw CustomError.genericError("サーバーエラーが発生しました。")
    }
    // dataをUIImage型に変換できない場合エラー
    guard let image = UIImage(data: data) else {
        throw CustomError.genericError("画像データが不正です。")
    }
    // 戻り値：画像
    return image
}


//ログアウト
func logout(AppLoginUserInfo: LoginUserInfo) throws -> Bool  {
    do {
        //ログアウト
        try Auth.auth().signOut()

        // 状態リセット
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

        return true

    } catch let signOutError as NSError {
        print("ログアウトエラー: %@", signOutError)
        return false
    }
}

// ***************************
// ログイン状態チェック用クラス
// ***************************
class LoginStatusChecker: ObservableObject {
    // ログインユーザ状態チェック
    func checkLoginStatus() async throws -> Int {
        // 戻り値
        var returnCode :Int? = nil
        // Firebaseの状態を確認
        if let user = Auth.auth().currentUser {
            do {
                // currentUserオブジェクトを更新(リロードしないとisEmailVerifiedが更新されない)
                try await user.reload()
            } catch {
                print("ユーザリロードエラー: \(error.localizedDescription)")
                return returnCode ?? 0
            }
            // Email認証チェック
            if user.isEmailVerified {
                do {
                    // ユーザ名登録状態をチェック　未登録は"2" 登録済は"3"
                    let isNameRegistered = try await self.checkDocumentExists(user: user)
                    returnCode = isNameRegistered ? 3 : 2
                } catch {
                    print("ドキュメント存在チェックエラー")
                    return returnCode ?? 0
                }
            } else {
                // Email未認証
                returnCode = 1
            }
        } else {
            // ログインしていない
            returnCode = 0
        }
        return returnCode ?? 0
    }

    // ドキュメントIDが存在するかチェック
    private func checkDocumentExists(user: User) async throws -> Bool {
        let db = Firestore.firestore()
        let docRef = db.collection(FirestoreCollections.users).document(user.uid)
        let docSnapshot = try await docRef.getDocument()
        return docSnapshot.exists
    }
}


// ******************
// Extension 継承(拡張)
// ******************
// User.reloadの非同期版を自作
extension User {
    func reload() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.reload { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

//例外処理(カスタム文字列)
enum CustomError: Error {
    case genericError(String)
}

