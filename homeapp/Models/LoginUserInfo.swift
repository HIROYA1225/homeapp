import SwiftUI
import FirebaseFirestore

//ログインユーザ情報保持クラス
class LoginUserInfo: ObservableObject {
    //ユーザ情報Auth
    @Published var userUid = ""
    @Published var email = ""

    //ユーザ情報usersコレクション
    @Published var userName = ""
    @Published var gender = ""
    @Published var age = ""
    @Published var residence = ""
    @Published var introduction = ""
    @Published var profileImageFileName = ""
    @Published var createDate: Timestamp?
    @Published var updateDate: Timestamp?

    @Published var profileImage: Image?   //登録のプロフィール画像

}

