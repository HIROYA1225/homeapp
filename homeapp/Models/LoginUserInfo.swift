import SwiftUI

//ログインユーザ情報保持クラス
class LoginUserInfo: ObservableObject {
    //状態bool
    @Published var isLoading: Bool = true
    @Published var isRegisterAuth: Bool = false  //Auth登録bool
    @Published var isMailConfirm: Bool = false  //メール認証完了bool
    @Published var isRegisterName: Bool = false  //名前設定済かどうか
    @Published var isLoggedIn: Bool = false  //ログイン状態

    //ユーザ情報Auth
    @Published var userUid = ""
    @Published var email = ""

    //ユーザ情報usersコレクション
    @Published var userEmail = ""
    @Published var userName = ""
    @Published var gender = ""
    @Published var age: String = ""
    @Published var residence = ""
    @Published var introduction = ""
    @Published var profileImageFileName = ""
    @Published var createDate = ""
    @Published var updateDate = ""

    @Published var profileImage: Image?   //登録のプロフィール画像

}

