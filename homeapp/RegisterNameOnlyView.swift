//
//  RegisterNameOnlyView.swift
//  homeapp
//
//  Created by Ryota on 2023/11/05.
//

import SwiftUI
import FirebaseAuth
import Firebase

// ユーザ名登録画面
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
                            print(self.returnMessage)
                            // トップ画面に遷移
                            // path.append("toLoginCheck")
                        } else {
                            // todo アラート表示お願い
                            self.returnMessage = "ユーザ名登録でエラーが発生しました。"

                        }
                    } catch {
                        print(error)
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

        // ユーザuid取得(ログインしていない場合は、falseを返す)
        guard let userUid = Auth.auth().currentUser?.uid else {
            return false
        }

        // Firebase設定
        let db = Firestore.firestore()
        // ドキュメントIDはユーザuid
        let usersDocRef = db.collection(FirestoreCollections.users).document(userUid)
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
