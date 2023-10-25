//
//  homeappApp.swift
//  homeapp
//
//  Created by HIRO on 2023/08/08.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct homeappApp: App {

    //Firebase初期処理
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //ログインユーザ情報保持クラス
    @StateObject var AppLoginUserInfo = LoginUserInfo()

    var body: some Scene {
        WindowGroup {
            ProfileView()
            // ログイン画面
//            loginView()
//                .environmentObject(AppLoginUserInfo)
        }
    }
}


// ***************************************************************
// 認証機能を使うため以下を記載 & Firebaseの初期化処理もここで実施
// ***************************************************************
class AppDelegate: NSObject, UIApplicationDelegate {
    //メールアドレス認証用 & Firebaseの初期化処理(1度のみ呼び出されることが保証されるため関数内に記載推奨)
    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    //Google認証使うために記載
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

