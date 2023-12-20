import Foundation
import SwiftUI
struct SettingView: View {
    @EnvironmentObject var AppLoginUserInfo: LoginUserInfo
    var body: some View {
        ZStack {
            // 背景部分
            GeometryReader { geometry in
                EmptyView()
            }
            .background(Color.gray.opacity(0.3))
            // リスト部分
            HStack {
                VStack() {
                    NavigationLink(destination: ChangeMail()) {
                        MenuContentView(topPadding: 100,text: "メースアドレス変更")
                    }
                    NavigationLink(destination: ChangePass()) {
                        MenuContentView(text: "パスワード変更")
                    }
                    NavigationLink(destination: RegisterPremium()) {
                        MenuContentView(text: "プレミアム会員登録")
                    }
                    Spacer()
                    Button(action: {
                        do {
                            if try logout(AppLoginUserInfo: AppLoginUserInfo) {
                                print("ログアウト成功")
                            }
                        } catch {
                            print("Failed to sign out")
                        }
                    }){
                        MenuContentView(text: "ログアウト")
                    }
                    NavigationLink(destination: DeleteUser()) {
                        MenuContentView(text: "退会")
                    }
                    Spacer()
                    
                }
                .background(Color(UIColor.systemGray6))
                Spacer()
            }
        }
    }
}
struct MenuContentView: View {
    var topPadding: CGFloat = 0
    var text: String
    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(.gray)
                .font(.headline)
            Spacer()
        }
        .padding(.top, topPadding)
        .padding(.bottom, 20)
        .padding(.leading, 20)
        .padding(.trailing, 70)
    }
}
