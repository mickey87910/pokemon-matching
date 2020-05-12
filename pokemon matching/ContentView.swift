//
//  ContentView.swift
//  pokemon matching
//
//  Created by mickey on 2020/5/8.
//  Copyright © 2020 mickey. All rights reserved.
//

import SwiftUI
let pokemonList = ["皮卡丘","伊布","小火龍"]
var pokemon1DTable:[String] = []
var pokemon2DTable:[[String]] = []
var tableWidth = 4
var tableHeight = 4
func GameStart(){
    //取出n*n的寶可夢
    for _ in 0...tableWidth*tableHeight/2-1 {
        if let pokemon = pokemonList.randomElement(){
            //寶可夢兩個同種類為一組
            pokemon1DTable.append(pokemon)
            pokemon1DTable.append(pokemon)
        }
    }
    //打散寶可夢的排序
    pokemon1DTable.shuffle()
    //將打散好的寶可夢添入二維陣列
    var k = 0
    for i in 0...tableHeight-1{
        pokemon2DTable.append([])
        for _ in 0...tableWidth-1{
            pokemon2DTable[i].append(pokemon1DTable[k])
            k+=1
        }
    }
}
func shuffleTable(table:[[String]])-> [[String]]{
    var tmpTable:[String] = []
    var newTable:[[String]] = []
    for i in 0...tableHeight-1{
        for j in 0...tableWidth-1{
            tmpTable.append(table[i][j])
        }
    }
    tmpTable.shuffle()
    //將打散好的寶可夢添入二維陣列
    var k = 0
    for i in 0...tableHeight-1{
        newTable.append([])
        for _ in 0...tableWidth-1{
            newTable[i].append(tmpTable[k])
            k+=1
        }
    }
    return newTable
}
struct ContentView: View {
    @State var showGameView : Bool = false //切換頁面判斷
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
                    }
                }
                Button(action:{
                    print("213")
                }){
                    Text("遊戲設定")
                        .padding()
                        .font(.system(size: 26))
                        .border(Color.blue,width:5)
                        .cornerRadius(8)
                        .padding()
                }
                Button(action:{
                    print("213")
                }){
                    Text("遊戲說明")
                        .padding()
                        .font(.system(size: 26))
                        .border(Color.blue,width:5)
                        .cornerRadius(8)
                }
            }
        }.frame(minWidth:0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
    }
}
struct GameView: View{
    @State var Table = pokemon2DTable
    var body: some View{
        VStack{
            Button(action:{
                self.Table = shuffleTable(table:self.Table)
            }){
                Text("洗牌")
            }
            ForEach(0...tableHeight-1,id:\.self){ i in
                HStack{
                    ForEach(0...tableWidth-1,id:\.self){ j in
                        Image("\(self.Table[i][j])")
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
