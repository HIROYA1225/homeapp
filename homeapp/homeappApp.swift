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
    // ログイン状態監視用リスナー
    @State private var authListenerHandle: AuthStateDidChangeListenerHandle?
    // Firebaseの状態を確認するための状態変数
    @State private var viewSelector: Int? = nil

    var body: some Scene {
        WindowGroup {
            Group {
                if viewSelector == nil {
                    // ローディング画面を表示する
                    LoadingView()
                } else {
                    switch viewSelector {
                    case 0:
                        // ログインしていない場合
                        loginView().environmentObject(AppLoginUserInfo)
                    case 1:
                        // ログイン済み、Email未認証の場合
                        iraiEmailConfirmView().environmentObject(AppLoginUserInfo)
                    case 2:
                        // ログイン済み、Email認証済み、Usersコレクション名前未登録の場合
                        RegisterNameOnlyView().environmentObject(AppLoginUserInfo)
                    case 3:
                        // ログイン済み、Email認証済み、Usersコレクション名前登録済みの場合
                        homeView().environmentObject(AppLoginUserInfo)
                    default:
                        loginView().environmentObject(AppLoginUserInfo)
                    }
                }
            }
            .onAppear {
                // インスタンス化させる必要あり
                let loginChecker = LoginStatusChecker()
                Task {
                    do {
                        // ログインユーザ状態チェック
                        viewSelector = try await loginChecker.checkLoginStatus()
                        // Firebase Authの状態変更を監視
                        authListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
                            Task {
                                do {
                                    // 状態が変更されたときにログインユーザ状態を再チェック
                                    viewSelector = try await loginChecker.checkLoginStatus()
                                } catch {
                                    // todo エラー処理
                                    print(error)
                                }
                            }
                        }
                    } catch {
                        // todo エラー処理
                        print(error)
                    }
                }
            }
            .onDisappear {
                // リスナーを削除します
                if let handle = authListenerHandle {
                    Auth.auth().removeStateDidChangeListener(handle)
                }
            }
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










