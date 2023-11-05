//
//  iraiEmailConfirm.swift
//  homeapp
//
//  Created by Ryota on 2023/11/05.
//

import SwiftUI

// todo メールを再送するボタンとその処理
struct iraiEmailConfirmView: View {

    var body: some View {
        NavigationView {
            VStack {
                Text("メールアドレスの確認を行なってください。")

                NavigationLink(destination: loginView()) {
                    Text("ログイン画面に戻る")
                }
            }
        }
    }
}

struct iraiEmailConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        iraiEmailConfirmView()
    }
}
