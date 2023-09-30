//
//  registerView.swift
//  homeapp
//
//  Created by HIRO on 2023/08/22.
//

import SwiftUI
import FirebaseAuth

struct registerView: View {
    @State var email = ""
    @State var password = ""
    @State var isUserRegistered = false // ユーザー登録成功フラグ
    @State var isSendMail = false // 確認用メール送信成功フラグ
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
            Button(action:registerUser) {
                Text("登録")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15.0)
            }
            //登録成功時、Email成功時 todoshi
            //名前入力画面やメール認証してください画面へ遷移させる必要があると思う。
            if isUserRegistered {
                if isSendMail {

                }
            }
        }
    }

    //Email認証登録処理
    private func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // todoshi 登録エラー時の処理
                print("ユーザ登録失敗: \(error.localizedDescription)")
            } else if let user = authResult?.user {
                self.isUserRegistered = true //ユーザ登録完了フラグ

                // メールアドレス確認メールの送信
                user.sendEmailVerification { error in
                    if let error = error {
                        // todoshi 登録エラー時の処理
                        print("ユーザ登録認証メールの送信失敗: \(error.localizedDescription)")
                    } else {
                        self.isSendMail = true //メール送信成功フラグ
                    }
                }
            }
        }
    }

}

struct registerView_Previews: PreviewProvider {
    static var previews: some View {
        registerView()
    }
}

