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

//プロフィール画像取得処理
func getProfileImage(AppLoginUserInfo: LoginUserInfo) async throws -> Void {





    // ********************************************************
    // 関数内の処理方法はprofileeditブランチで書き換えたからそっちを使用
    // ********************************************************





    //    //uiImageとImage型変換用
    //    var uiImageProf: UIImage?
    //
    //    //デフォルト画像
    //    AppLoginUserInfo.profileImage = Image(AppImageName.ProfileImageNoSet_icon)
    //
    //    //登録画像がある場合、
    //    let profileImageFileName = AppLoginUserInfo.profileImageFileName
    //    if !profileImageFileName.isEmpty {
    //        //画像パス作成
    //        let imgDir = URL(string: FirebaseStorage.profileImageDirName)!
    //        let imgDirWithSubfolder = imgDir.appendingPathComponent(AppLoginUserInfo.userUid)
    //        let proImgFullPath = imgDirWithSubfolder.appendingPathComponent(profileImageFileName).absoluteString
    //
    //        let storage = Storage.storage()
    //        let storageRef = storage.reference()
    //        let imagesRef = storageRef.child(proImgFullPath)
    //
    //        // FirebaseStrageよりプロフィール画像を取得する
    //        imagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
    //            if let error = error {
    //                print("登録プロフィール画像取得失敗: \(error)")
    //            } else if let data = data {
    //                uiImageProf = UIImage(data: data)
    //                AppLoginUserInfo.profileImage = Image(uiImage: uiImageProf!)
    //            }
    //        }
    //    }


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
