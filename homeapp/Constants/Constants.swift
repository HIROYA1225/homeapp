//*****
//定数
//*****

import SwiftUI

//コレクション名
struct FirestoreCollections {
    static let users = "users"
}
//フィールド名
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
