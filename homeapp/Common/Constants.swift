//*****
//定数
//*****

import SwiftUI

//Firebaseコレクション名
struct FirestoreCollections {
    static let users = "users"
}
//Firebaseフィールド名
struct FirestoreFields {
    struct Users {
        static let userEmail = "userEmail"
        static let userName = "userName"
        static let gender = "gender"
        static let age = "age"
        static let residence = "residence"
        static let introduction = "introduction"
        static let profileImageFileName = "profileImageFileName"
        static let createDate = "createDate"
        static let updateDate = "updateDate"
    }
}

//FirebaseStrage
struct FirebaseStorage {
    static let profileImageDirName = "profileImage"
}

// アプリ内画像ファイル名
struct AppImageName {
    static let ProfileImageNoSet_icon = "ProfileImageNoSet_icon"
}



