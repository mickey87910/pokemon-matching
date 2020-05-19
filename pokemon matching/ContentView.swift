//
//  ContentView.swift
//  pokemon matching
//
//  Created by mickey on 2020/5/8.
//  Copyright © 2020 mickey. All rights reserved.
//

import SwiftUI
import AVFoundation
let pokemonList = ["皮卡丘","伊布","小火龍","耿鬼","妙娃種子","百變怪","卡比獸","鯉魚王"]
var pokemon1DTable:[String] = []
var pokemon2DTable:[[String]] = []
var path:[Pokemon] = [] //兩者路徑
var tableWidth = 12
var tableHeight = 6
var score = 0 //分數
var level = "" //難易度
var refreshTimes = 3 //洗牌次數
var tipsTimes = 3 //提示次數
var titleAudioPlayer : AVAudioPlayer?
var audioPlayer : AVAudioPlayer?
func playSound(sound:String){
    if let path = Bundle.main.path(forResource: sound, ofType: "mp3"){
        do{
            if (sound == "DragonQuestTitleMusic"){
                titleAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                titleAudioPlayer?.numberOfLoops = -1//無限迴圈
                titleAudioPlayer?.play()
            }else{
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.setVolume(0.6,fadeDuration: 1)
            audioPlayer?.play()
            print("播放音樂")
            }
        }catch{
            print("file not found")
        }
    }
}
func GameStart(){
    //取出n*n的寶可夢
    pokemon1DTable = []
    pokemon2DTable = []
    path = []
    score = 0
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
    if (times > 2 || nodeX < 0 || nodeX >= Table[0].count || nodeY < 0 || nodeY >= Table.count || containFlag){
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
    //決定尋找方向的順序
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
struct ContentView: View { //主畫面
    @State var showGameView : Bool = false //切換頁面判斷
    var body: some View {
        VStack{
            if showGameView{
                GameView()
            }else{
                VStack{
                    Spacer()
                    Image("標題").resizable()
                        .scaledToFit()
                        .onAppear(perform: {
                            playSound(sound: "DragonQuestTitleMusic")
                        })
                    Spacer()
                }
                HStack{
                    Button(action:{
                        //要執行的內容
                        GameStart()
                        self.showGameView = true
                        titleAudioPlayer?.stop()
                        playSound(sound: "press")
                    }){
                        //按鈕樣式設定
                        Text("開始遊戲")
                            .padding()
                            .font(.system(size: 26))
                            .background(Color.white)
                            .border(Color.blue,width:3)
                            .cornerRadius(8)
                    }
                    
                    Button(action:{
                        print("213")
                        playSound(sound: "press")
                    }){
                        Text("遊戲設定")
                            .padding()
                            .font(.system(size: 26))
                            .background(Color.white)
                            .border(Color.blue,width:3)
                            .cornerRadius(8)
                            .padding()
                    }
                    
                    Button(action:{
                        print("213")
                        playSound(sound: "press")
                    }){
                        Text("遊戲說明")
                            .padding()
                            .background(Color.white)
                            .font(.system(size: 26))
                            .border(Color.blue,width:3)
                            .cornerRadius(8)
                    }
                }
            }
        }.frame(minWidth:0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity).edgesIgnoringSafeArea(.all).background(Image("星空"))//.background(Color(red:187/255.0,green:255/255.0,blue:180/255.0))
    }
}
struct GameView: View{ //遊戲介面
    @State var Table = pokemon2DTable
    @State var selectA = Pokemon()
    @State var selectB = Pokemon()
    @State var tipsA = Pokemon()
    @State var tipsB = Pokemon()
    var body: some View{
        VStack{
            HStack{
                Button(action:{
                    GameStart()
                    self.Table = pokemon2DTable
                }){
                    Image("close").foregroundColor(Color.red)
                }
                Spacer()
                
                Button(action:{
                    //do 提示
                    if (tipsTimes > 0) {
                        playSound(sound: "spell")
                        tipsTimes -= 1
                    }
                }){
                    Image("tips").foregroundColor(Color.green)
                }
                Text("提示:")
                    .font(.system(size:32))
                Text("\(tipsTimes)")
                    .font(.system(size: 32))
                Button(action:{
                    if( refreshTimes > 0){
                        playSound(sound: "spell")
                        for item in path{
                            self.Table[item.y!][item.x!] = "無"
                        }
                        path = []
                        self.Table = shuffleTable(table:self.Table)
                        refreshTimes -= 1
                        
                    }
                }){
                    Image("refresh").foregroundColor(Color.blue)
                }
                
                Text("洗牌:")
                    .font(.system(size: 32))
                Text("\(refreshTimes)")
                    .font(.system(size: 32))
                
                
                Text("分數:")
                    .font(.system(size: 32))
                Text("\(score)")
                    .fixedSize()
                    .font(.system(size: 32))
                    .frame(width:100)
                
            }.frame(minWidth:0,maxWidth: .infinity).background(Color.yellow)
            HStack{
                Spacer()//左側
                VStack{//中間位置
                    ForEach(0...tableHeight-1,id:\.self){ i in
                        HStack{
                            ForEach(0...tableWidth-1,id:\.self){ j in
                                Button(action:{
                                    //Button Action
                                    print("\(self.Table[i][j])(\(j),\(i))")
                                    if (self.Table[i][j] == "無" || self.Table[i][j] == "星星"){
                                        self.selectA = Pokemon()
                                        self.selectB = Pokemon()
                                    }else{
                                        if (self.selectA.name != nil){
                                            //如果A可夢已經被選取則設定B可夢
                                            self.selectB.name = self.Table[i][j]
                                            self.selectB.x = j
                                            self.selectB.y = i
                                            if (self.selectA.name == self.selectB.name && (self.selectA.x != self.selectB.x || self.selectA.y != self.selectB.y) ){//名字相同且不同位置
                                                path = []
                                                if(findpath(nodeX:self.selectA.x!,nodeY:self.selectA.y!,destinationX:self.selectB.x!,destinationY:self.selectB.y!,Table:self.Table)){
                                                    //如果有找到連接之路徑則顯示路徑
                                                    for item in path{
                                                        self.Table[item.y!][item.x!] = "星星"
                                                    }
                                                    score = score + 100
                                                    playSound(sound: "hit")
                                                }else{
                                                    //如果找不到連接之路徑
                                                    print("找無路徑")
                                                    playSound(sound:"miss")
                                                }
                                            }else{//名字不相同或者點選到同一隻
                                                print("取消選擇")
                                                playSound(sound:"miss")
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
                                            playSound(sound: "select")
                                        }
                                    }
                                    //Button Action
                                }){
                                    //ButtonStyle
                                    if(self.selectA.x == j && self.selectA.y == i){
                                        Image("\(self.Table[i][j])")
                                            .border(Color.blue,width:2.0)
                                    }else{
                                        Image("\(self.Table[i][j])")
                                    }
                                }.buttonStyle(PlainButtonStyle())//避免按鈕顏色覆蓋圖片
                            }
                        }
                    }
                }
                Spacer()//右側
            }
            Spacer()
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewLayout(.fixed(width:896,height:414))
    }
}
