//
//  registerView.swift
//  homeapp
//
//  Created by HIRO on 2023/08/22.
//

import SwiftUI
import FirebaseAuth

struct registerView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isUserRegistered = false // ユーザー登録成功フラグ
    @State private var isSendMail = false // 確認用メール送信成功フラグ
    @State private var returnErrorMessage = ""

    var body: some View {
        VStack(){
            Text("新規登録")
                .font(.largeTitle).foregroundColor(Color.black)
                .padding([.top, .bottom], 40)
            TextField("Email", text:self.$email)
                .padding()
                .cornerRadius(20.0)
                .autocapitalization(.none)
            SecureField("Password", text:self.$password)
                .padding()
                .cornerRadius(20.0)
            Button(action: {
                Task {
                    do {
                        if email.isEmpty || password.isEmpty {
                            // todo アラート表示お願い("メールアドレスとパスワードを入力してください"のような)
                            return
                        }
                        //登録処理
                        if try await registerUser() {
                            // todo 仮登録完了しました。メールの確認を行い、再度ログインしてください。みたいなメッセージを出して、ログイン画面に遷移させるか。
                        } else {
                            //todo アラート アラートエラーメッセージ表示お願い(基本的なエラーはcatchで対処されるが、念のため「エラーが発生しました。」のようなエラーアラートを出す)
                        }
                    } catch {
                        self.returnErrorMessage = handleFirebaseAuthSignupError(error)
                        //todo アラート アラートエラーメッセージ表示お願い(returnErrorMessageを表示させて)
                    }
                }

            }) {
                Text("登録")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15.0)
            }
        }
    }

    //Email認証登録処理
    private func registerUser() async throws -> Bool {

        return try await withCheckedThrowingContinuation { continuation in

            // Auth登録処理
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
                if let error = error {
                    // todo ユーザ登録失敗のログ出力する？確認メール送信失敗と区別するために
                    continuation.resume(throwing: error)
                } else if let user = authResult?.user {
                    self.isUserRegistered = true //ユーザ登録完了フラグ

                    // メールアドレス確認メールの送信
                    user.sendEmailVerification { error in
                        if let error = error {
                            // todo ユーザ登録失敗のログ出力する？確認メール送信失敗と区別するために
                            continuation.resume(throwing: error)
                        } else {
                            //ユーザ登録&メール送信成功時
                            self.isSendMail = true //メール送信成功フラグ
                            continuation.resume(returning: true)
                        }
                    }
                }
            }
        }
    }

    // エラー処理
    private func handleFirebaseAuthSignupError(_ error: Error) -> String {
        var returnMessage = ""
        if let errorCode = AuthErrorCode.Code(rawValue: (error as NSError).code) {
            switch errorCode {
            case .invalidEmail:
                returnMessage = "入力されたメールアドレスの形式が正しくありません。"
            case .weakPassword:
                returnMessage = "パスワードが弱すぎます。6文字以上の強固なものを設定してください。"
            case .emailAlreadyInUse:
                returnMessage = "入力されたメールアドレスは既に使用されています。"
            case .networkError:
                returnMessage = "通信エラーが発生しました。ネットワークの状態を確認してください。"
            default:
                returnMessage = "Signup時にエラーが発生しました。アプリを閉じて再度お試しください。"
            }
        }
        return returnMessage
    }


}

struct registerView_Previews: PreviewProvider {
    static var previews: some View {
        registerView()
    }
}

