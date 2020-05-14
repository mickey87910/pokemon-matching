//
//  ContentView.swift
//  pokemon matching
//
//  Created by mickey on 2020/5/8.
//  Copyright © 2020 mickey. All rights reserved.
//

import SwiftUI
let pokemonList = ["皮卡丘","伊布","小火龍","耿鬼","妙娃種子"]
var pokemon1DTable:[String] = []
var pokemon2DTable:[[String]] = []
var path:[Pokemon] = []
var tableWidth = 6
var tableHeight = 6
var scroe = 0
func GameStart(){
    //取出n*n的寶可夢
    pokemon1DTable = []
    pokemon2DTable = []
    path = []
    scroe = 0
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
    //打散寶可夢的排序
    tmpTable.shuffle()
    //將打散好的寶可夢重新添入二維陣列
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
func findpath(nodeX:Int,nodeY:Int,destinationX:Int,destinationY:Int,Table:[[String]],nodes:[Pokemon] = [],times:Int = 0,direction:String = "NONE")->Bool{
    //初始化參數 & let to var
    var nodes = nodes
    var flag = false
    var directionList:[String] = []
    //將當前 node 加入 nodes 陣列
    var node = Pokemon()
    node.x = nodeX
    node.y = nodeY
    let containFlag = nodes.contains{ (pokemon) -> Bool in
        //查看當前節點是否已經走過了
        return pokemon.x == node.x && pokemon.y == node.y
    }
    if (times > 2 || nodeX < 0 || nodeX >= Table.count || nodeY < 0 || nodeY >= Table[0].count || containFlag){
        //轉彎超過兩次或者節點超過表格大小以及該節點是否已經走過
        return false
    }else{
        nodes.append(node)
        if (nodeX == destinationX && nodeY == destinationY){
            //如果當前這個位置抵達目的地
            path = nodes
            return true
        }else if(Table[nodeY][nodeX] != "無" && direction != "NONE"){
            //如果當前節點不可行走(初始起點不算)
            return false
        }else{
            if (nodeX > destinationX && nodeY > destinationY){ directionList = getDirectionList(location: "左上")}//若目的地在節點左上
            else if(nodeX > destinationX && nodeY < destinationY){ directionList = getDirectionList(location: "左下")}//若目的地在節點左下
            else if(nodeX < destinationX && nodeY > destinationY){ directionList = getDirectionList(location: "右上")}//若目的地在節點右上
            else if(nodeX < destinationX && nodeY < destinationY){ directionList = getDirectionList(location: "右下")}//若目的地在節點右上
            else if(nodeX == destinationX && nodeY != destinationY){ directionList = getDirectionList(location: "上下")}//若目的地在節點上下
            else if(nodeX != destinationX && nodeY == destinationY){ directionList = getDirectionList(location: "左右")}//若目的地在節點左右
            print(directionList)
            for i in 0...3{
                var x = 0
                var y = 0
                if (directionList[i] == "LEFT"){x = -1;y = 0}
                else if (directionList[i] == "RIGHT"){x = 1;y = 0}
                else if (directionList[i] == "UP"){x = 0;y = -1}
                else if (directionList[i] == "DOWN"){x = 0;y = 1}
                
                if(flag != true){
                    if (direction == directionList[i] || direction == "NONE"){
                        flag = findpath(nodeX: nodeX+x, nodeY: nodeY+y, destinationX: destinationX, destinationY: destinationY, Table: Table, nodes: nodes, times: times, direction: directionList[i])
                    }else{
                        //如果將行走方向與原方向不同代表轉彎
                        flag = findpath(nodeX: nodeX+x, nodeY: nodeY+y, destinationX: destinationX, destinationY: destinationY, Table: Table, nodes: nodes, times: times+1, direction: directionList[i])
                    }
                }
            }
        }
    }
    return flag
}
func getDirectionList(location:String)->[String]{
    switch location {
    case "右上":
        return ["RIGHT","UP","LEFT","DOWN"]
    case "右下":
        return ["RIGHT","DOWN","LEFT","UP"]
    case "左上":
        return ["LEFT","UP","RIGHT","DOWN"]
    case "左下":
        return ["LEFT","DOWN","RIGHT","UP"]
    case "上下":
        return ["UP","DOWN","LEFT","RIGHT"]
    case "左右":
        return ["LEFT","RIGHT","UP","DOWN"]
    default:
        return []
    }
}
struct Pokemon{
    var name:String?
    var x:Int?
    var y:Int?
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
    @State var selectA = Pokemon()
    @State var selectB = Pokemon()
    var body: some View{
        VStack{
            HStack{
                Button(action:{
                    self.Table = shuffleTable(table:self.Table)
                }){
                    Text("洗牌")
                }
                Button(action:{
                    GameStart()
                    self.Table = pokemon2DTable
                }){
                    Text("重新開始")
                }
            }
            ForEach(0...tableHeight-1,id:\.self){ i in
                HStack{
                    ForEach(0...tableWidth-1,id:\.self){ j in
                        Button(action:{
                            print("\(self.Table[i][j])(\(j),\(i))")
                            if (self.Table[i][j] == "無"){
                                self.selectA = Pokemon()
                                self.selectB = Pokemon()
                            }else{
                                if (self.selectA.name != nil){
                                    //如果A可夢已經被選取則設定B可夢
                                    self.selectB.name = self.Table[i][j]
                                    self.selectB.x = j
                                    self.selectB.y = i
                                    if (self.selectA.name == self.selectB.name && (self.selectA.x != j || self.selectA.y != i) ){//名字相同且不同位置
                                        path = []
                                        if(findpath(nodeX:self.selectA.x!,nodeY:self.selectA.y!,destinationX:self.selectB.x!,destinationY:self.selectB.y!,Table:self.Table)){
                                            //如果有找到連接之路徑則顯示路徑
                                            for item in path{
                                                self.Table[item.y!][item.x!] = "星星"
                                            }
                                            self.Table[i][j] = "星星"
                                            self.Table[self.selectA.y!][self.selectA.x!] = "星星"
                                        }else{
                                            //如果找不到連接之路徑
                                            print("找無路徑")
                                        }
                                    }else{//名字不相同或者點選到同一隻
                                        print("取消選擇")
                                    }
                                    //重設
                                    self.selectA = Pokemon()
                                    self.selectB = Pokemon()
                                }else{//如果還沒選則設定A可夢
                                    self.selectA.name = self.Table[i][j]
                                    self.selectA.x = j
                                    self.selectA.y = i
                                    for item in path{
                                        self.Table[item.y!][item.x!] = "無"
                                    }
                                }
                            }
                        }){
                            Image("\(self.Table[i][j])")
                            
                        }.buttonStyle(PlainButtonStyle())//避免按鈕顏色覆蓋圖片
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
