//
//  homeView.swift
//  homeapp
//
//  Created by HIRO on 2023/08/22.
//

import SwiftUI
import Liquid

struct homeView: View {
    var body: some View {
        ZStack {
            Liquid()
                .frame(width: 240, height: 240)
                .foregroundColor(.blue)
                .opacity(0.3)

            Liquid()
                .frame(width: 220, height: 220)
                .foregroundColor(.blue)
                .opacity(0.5)

            Liquid()
                .frame(width: 200, height: 200)
                .foregroundColor(.blue)
                .opacity(0.6)
            
        }
    }
}

struct homeView_Previews: PreviewProvider {
    static var previews: some View {
        homeView()
    }
}
