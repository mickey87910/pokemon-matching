//
//  ContentView.swift
//  pokemon matching
//
//  Created by mickey on 2020/5/8.
//  Copyright © 2020 mickey. All rights reserved.
//

import SwiftUI
let pokemonList = ["皮卡丘","噴火龍","水箭龜","妙娃花"]
var pokemon1DTable:[String] = []
var pokemon2DTable:[[String]] = []
var tableWidth = 4
var tableHeight = 4
func GameStart(){
    for _ in 0...tableWidth*tableHeight/2-1 {
        if let pokemon = pokemonList.randomElement(){
            pokemon1DTable.append(pokemon)
            pokemon1DTable.append(pokemon)
        }
    }
    print(pokemon1DTable.count)
    pokemon1DTable.shuffle()
    var k = 0
    for i in 0...tableHeight-1{
        pokemon2DTable.append([])
        for j in 0...tableWidth-1{
            pokemon2DTable[i].append(pokemon1DTable[k])
            k+=1
        }
    }
}
struct ContentView: View {
    @State var showGameView : Bool = false //轉換頁面判斷
    var body: some View {
        VStack{
            if showGameView{
                GameView()
            }else{
                Text("寶可夢連連看")
                    .bold()
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)
                    .padding()
                HStack {
                    Button(action:{
                        //要執行的內容
                        GameStart()
                        self.showGameView = true
                    }){
                        //按鈕樣式設定
                        Text("開始遊戲")
                            .padding()
                            .font(.system(size: 26))
                            .border(Color.blue,width:5)
                            .cornerRadius(8)
                            .padding()
                    }
                }
                Button(action:{
                    print("213")
                }){
                    Text("遊戲說明")
                        .padding()
                        .font(.system(size: 26))
                        .border(Color.blue,width:5)
                        .cornerRadius(8)
                        .padding()
                }
            }
        }.frame(minWidth:0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
    }
}
struct GameView: View{
    var body: some View{
        VStack{
            ForEach(0...tableHeight-1,id:\.self){ i in
                HStack{
                    ForEach(0...tableWidth-1,id:\.self){ j in
                        Text("\(pokemon2DTable[i][j])")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewLayout(.fixed(width:896,height:414))
    }
}
