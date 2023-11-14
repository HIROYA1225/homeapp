//
//  tabView.swift
//  homeapp
//
//  Created by HIRO on 2023/09/27.
//

import Foundation
import SwiftUI

struct tabView: View {
    @State private var selection = 0
    var body: some View {
        TabView(selection: $selection){
            homeView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(0)
            RecordView()
                .tabItem {
                    Image(systemName: "speaker.wave.3.fill")
                }
                .tag(1)
            RankingView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                }
                .tag(2)
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
                .tag(3)
            
        }
    }
}
struct tabView_Previews: PreviewProvider {
    static var previews: some View {
        tabView()
    }
}


