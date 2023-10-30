//
//  RankingView.swift
//  homeapp
//
//  Created by YOSUKE on 2023/10/30.
//

import SwiftUI

struct RankingView: View {
    @State private var period = ""

    let period_list = ["総合", "年間", "月間", "週間"]
    
    private let width:CGFloat = 120


    var body: some View {
        VStack{
            Text("ほめランキング")
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .background(Color.cyan)
            
            //期間
            Picker("", selection: self.$period) {
                ForEach(period_list, id: \.self) { item in
                    Text(item)
                }
            }
            
            HStack(spacing:40){
                //2位ユーザー
                VStack(spacing:5){
                    Spacer().frame(height:40)
                    VStack(spacing:0){
                        Image(systemName: "crown.fill")     //王冠
                            .resizable()
                            .scaledToFit()
                            .frame(width: width/3, height: width/3)
                            .foregroundColor(.gray)
                        Image(systemName: "person.crop.circle")     //ユーザーアイコン
                            .resizable()
                            .scaledToFit()
                            .frame(width: width*2/3, height: width*2/3)
                            .foregroundColor(.black)
                    }
                    Text("ユーザーB")    //ユーザー名
                    HStack{
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width/8, height: width/8)
                            .foregroundColor(.red)
                        Text("2564")
                    }
                }
    
                //1位ユーザー
                VStack(spacing:5){
                    VStack(spacing:0){
                        Image(systemName: "crown.fill")     //王冠
                            .resizable()
                            .scaledToFit()
                            .frame(width: width/3, height: width/3)
                            .foregroundColor(.yellow)
                        Image(systemName: "person.crop.circle")     //ユーザーアイコン
                            .resizable()
                            .scaledToFit()
                            .frame(width: width*2/3, height: width*2/3)
                            .foregroundColor(.black)
                    }
                    Text("ユーザーA")    //ユーザー名
                    HStack{
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width/8, height: width/8)
                            .foregroundColor(.red)
                        Text("2564")
                    }
                }
                
                //3位ユーザー
                VStack(spacing:5){
                    Spacer().frame(height:60)
                    VStack(spacing:0){
                        Image(systemName: "crown.fill")     //王冠
                            .resizable()
                            .scaledToFit()
                            .frame(width: width/3, height: width/3)
                            .foregroundColor(.orange)
                        Image(systemName: "person.crop.circle")     //ユーザーアイコン
                            .resizable()
                            .scaledToFit()
                            .frame(width: width*2/3, height: width*2/3)
                            .foregroundColor(.black)
                    }
                    Text("ユーザーC")    //ユーザー名
                    HStack{
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width/8, height: width/8)
                            .foregroundColor(.red)
                        Text("2564")
                    }
                }
            }
            
            //4位以下
            VStack{
                HStack{
                    Text("4") //順位
                    Text("")
                    Image(systemName: "person.crop.circle")     //ユーザーアイコン
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/4, height: width/4)
                        .foregroundColor(.black)
                    Text("ユーザーD")
                    Spacer()
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/6, height: width/6)
                        .foregroundColor(.red)
                    Text("1111")    //いいね数
                }
                
                HStack{
                    Text("5")
                    Text("")
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/4, height: width/4)
                        .foregroundColor(.black)
                    Text("ユーザーD")
                    Spacer()
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/6, height: width/6)
                        .foregroundColor(.red)
                    Text("111")
                }
                
                HStack{
                    Text("6")
                    Text("")
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/4, height: width/4)
                        .foregroundColor(.black)
                    Text("ユーザーD")
                    Spacer()
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/6, height: width/6)
                        .foregroundColor(.red)
                    Text("111")
                }
                
                HStack{
                    Text("7")
                    Text("")
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/4, height: width/4)
                        .foregroundColor(.black)
                    Text("ユーザーD")
                    Spacer()
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/6, height: width/6)
                        .foregroundColor(.red)
                    Text("111")
                }
                
                HStack{
                    Text("8")
                    Text("")
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/4, height: width/4)
                        .foregroundColor(.black)
                    Text("ユーザーD")
                    Spacer()
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/6, height: width/6)
                        .foregroundColor(.red)
                    Text("111")
                }
                
                HStack{
                    Text("9")
                    Text("")
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/4, height: width/4)
                        .foregroundColor(.black)
                    Text("ユーザーD")
                    Spacer()
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/6, height: width/6)
                        .foregroundColor(.red)
                    Text("11")
                }
                
                HStack{
                    Text("10")
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/4, height: width/4)
                        .foregroundColor(.black)
                    Text("ユーザーD")
                    Spacer()
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width/6, height: width/6)
                        .foregroundColor(.red)
                    Text("1")
                }
                Spacer()
            }
            .font(.headline)
            .frame(width: width*2, height: width*2.3)
            .foregroundColor(.black)
            .padding()
            .background(Color.mint)
        }
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView()
    }
}
