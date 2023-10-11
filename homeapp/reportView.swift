//
//  reportView.swift
//  homeapp
//
//  Created by YOSUKE on 2023/10/07.
//

import SwiftUI

struct reportView: View {
    @State private var remarks = ""
    @State private var selectedIndex = 0
    @State private var CompleteAlert = false   // 完了アラートの表示フラグ
    @State private var DeleteAlert = false   // 削除アラートの表示フラグ
        
    let texts = ["プロフィール画像が不適切", "ユーザー名が不適切", "褒め言葉が不適切", "その他"]

    //画面触ったらキーボード閉じる処理の準備
    enum Field: Hashable {
        case userName
        case age
        case introduction
    }
    @FocusState private var focusedField: Field?
    var body: some View {
        VStack(spacing:30){
            
            HStack{
                Button(action:{}){
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.black)
                }
            }
            
            HStack{
                Text("通報する理由を以下から選択して下さい。")
                    .frame(width: UIScreen.main.bounds.width, height: 15)
            }
            
            VStack {
                RadioButton(selectedIndex: $selectedIndex, axis: .vertical, texts: texts)
            }
        
            VStack{
                Text("備考")
                    .frame(width: 220, height: 15, alignment:.leading)
                TextEditor(text:self.$remarks)
                    .keyboardType(.default)
                    .frame(width: 220,height: 100,alignment: .topLeading)
                    .border(Color.black,width: 1)
                    //画面触ったらキーボード閉じる処理
                    .focused($focusedField, equals: .introduction)
                    .onTapGesture {
                       focusedField = .introduction
                    }
            }
            
            Button("通報") {
                self.CompleteAlert = true          // タップされたら表示フラグをtrueにする
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(20.0)
            .alert(isPresented: $CompleteAlert) {  // アラートの表示条件設定
                Alert(title: Text("通報しました。"),     // アラートの定義
                    message: Text("ご協力ありがとうございました。"))
            }
         
            Button("削除アラート表示") {
                        self.DeleteAlert = true
                    }
                    .alert("現在の内容は削除されます。", isPresented: $DeleteAlert){
                        Button("キャンセル", role: .cancel){
                                        // キャンセルが押された時の処理
                        }
                        Button("削除", role: .destructive){
                                        // データ削除処理
                        }
                    } message: {
                        Text("よろしいですか？")
                    }
            
        }
        //画面触ったらキーボード閉じる処理
        .onTapGesture {
            focusedField = nil
        }
    }
}

struct reportView_Previews: PreviewProvider {
    static var previews: some View {
        reportView()
    }
}

//ラジオボタン
struct RadioButtonModel: Identifiable, Hashable {
    let id = UUID()
    let index: Int
    let text: String
    
    init(index: Int, text: String) {
        self.index = index
        self.text = text
    }
}

struct RadioButton: View {
    
    enum Axis {
        case horizontal
        case vertical
    }
    
    @Binding var selectedIndex: Int
    private let axis: Axis
    private var models: [RadioButtonModel] = []
    
    init(selectedIndex: Binding<Int>, axis: Axis, texts: [String]) {
        self._selectedIndex = selectedIndex
        self.axis = axis
        
        var index = 0
        texts.forEach { text in
            let model = RadioButtonModel(index: index, text: text)
            models.append(model)
            index += 1
        }
    }
    
    var body: some View {
        if axis == .vertical {
            return configureVertical()
        } else {
            return configureHorizontal()
        }
    }
    
    private func configureHorizontal() -> AnyView {
        return AnyView(
            HStack {
                configure()
            }
        )
    }
    
    private func configureVertical() -> AnyView {
        return AnyView(
            VStack(alignment: .leading) {
                configure()
            }
        )
    }
    
    private func configure() -> AnyView {
        return AnyView(
            ForEach(models) { model in
                HStack {
                    if model.index == self.selectedIndex {
                        ZStack {
                            Circle()
                                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2))
                                .frame(width: 20, height: 20)
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 12, height: 12)
                        }
                    } else {
                        Circle()
                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 2))
                            .frame(width: 20, height: 20)
                    }
                    Text(model.text)
                }
                .onTapGesture {
                    self._selectedIndex.wrappedValue = model.index
                }
            }
        )
    }
}
