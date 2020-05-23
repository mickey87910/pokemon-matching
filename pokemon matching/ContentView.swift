//
//  ContentView.swift
//  pokemon matching
//
//  Created by mickey on 2020/5/8.
//  Copyright © 2020 mickey. All rights reserved.
//

import SwiftUI
import AVFoundation
let pokemonList = ["皮卡丘","伊布","小火龍","耿鬼","妙娃種子","百變怪","卡比獸","鯉魚王","傑尼龜","向尾喵","小小象","地鼠","沼王","仙子伊布"]
var pokemon1DTable:[String] = []
var pokemon2DTable:[[String]] = []
var path:[Pokemon] = [] //兩者路徑
var tableWidth = 12
var tableHeight = 6
var score = 0 //分數
var level = "" //難易度
var refreshTimes = 30 //洗牌次數
var tipsTimes = 30 //提示次數
var gameTime = 180 //遊戲時間
var titleAudioPlayer : AVAudioPlayer? //主畫面音樂
var audioPlayer : AVAudioPlayer? //音效
func playSound(sound:String){
    if let path = Bundle.main.path(forResource: sound, ofType: "mp3"){
        do{
            if (sound == "DragonQuestTitleMusic"){//主畫面音樂
                titleAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                titleAudioPlayer?.numberOfLoops = -1//無限迴圈
                titleAudioPlayer?.play()
            }else{//其他音效
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.setVolume(0.6,fadeDuration: 1)
                audioPlayer?.play()
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
func findTips(Table:[[String]])->(Pokemon,Pokemon){
    var selectA = Pokemon()
    var selectB = Pokemon()
    for i in 0...tableHeight-1{
        for j in 0...tableWidth-1{
            if(Table[i][j] != "無" && Table[i][j] != "星星"){
                selectA.name = Table[i][j]
                selectA.x = j
                selectA.y = i
                for k in 0...tableHeight-1{
                    for m in 0...tableWidth-1{
                        if (selectA.name == Table[k][m] && (i != k || j != m) ){
                            selectB.name = Table[k][m]
                            selectB.x = m
                            selectB.y = k
                            if(findpath(nodeX: selectA.x!, nodeY: selectA.y!, destinationX: selectB.x!, destinationY: selectB.y!, Table: Table)){
                                return (selectA,selectB)
                            }
                        }
                    }
                }
            }
        }
    }
    selectA = Pokemon()
    selectB = Pokemon()
    return (selectA,selectB)
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
        return ["UP","RIGHT","LEFT","DOWN"]
    case "右下":
        return ["DOWN","RIGHT","LEFT","UP"]
    case "左上":
        return ["UP","LEFT","RIGHT","DOWN"]
    case "左下":
        return ["DOWN","LEFT","RIGHT","UP"]
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
    @State var showSetting : Bool = false //顯示遊戲設定
    @State var showIntroduction : Bool = false //顯示說明
    var body: some View {
        ZStack{
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
                            self.showIntroduction = false
                            self.showSetting = false
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
                            self.showSetting = true
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
                            self.showIntroduction = true
                            playSound(sound: "press")
                        }){
                            Text("遊戲說明")
                                .padding()
                                .background(Color.white)
                                .font(.system(size: 26))
                                .border(Color.blue,width:3)
                                .cornerRadius(8)
                        }
                    }//HSTACK
                }//else
            }//VSTACK
            if(self.showIntroduction || self.showSetting){
                ZStack{
                    VStack{
                        if(self.showSetting == true){ //遊戲設定視窗
                            Text("遊戲設定")
                                .font(.largeTitle)
                            Button(action:{
                                self.showSetting = false
                                playSound(sound: "press")
                            }){
                                Text("Close")
                                    .padding()
                                    .background(Color.white)
                                    .font(.system(size: 26))
                                    .border(Color.blue,width:3)
                                    .cornerRadius(8)
                            }
                        }else if(self.showIntroduction == true){ //遊戲說明視窗
                            Text("遊戲說明")
                                .font(.largeTitle)
                            Text("兩隻寶可夢間有路徑，並轉折兩次以內即可消除")
                            Button(action:{
                                self.showIntroduction = false
                                playSound(sound: "press")
                            }){
                                Text("Close").padding()
                                    .background(Color.white)
                                    .font(.system(size: 26))
                                    .border(Color.blue,width:3)
                                    .cornerRadius(8)
                            }
                        }
                    }.frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height*2/3, alignment: .center).background(Color.white)
                }.frame(minWidth:0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity).edgesIgnoringSafeArea(.all).background(Color.black.opacity(0.5))
            }
        }.frame(minWidth:0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity).edgesIgnoringSafeArea(.all).background(Image("星空"))//.background(Color(red:187/255.0,green:255/255.0,blue:180/255.0))
    }
}
func getImage(selectA:Pokemon,tipsA:Pokemon,tipsB:Pokemon,j:Int,i:Int,Table:[[String]],showAnimation:Bool,showAnimationB:Bool)->AnyView{
    let inPath = path.contains{ (pokemon) -> Bool in
        //查看當前節點是否為路徑
        return pokemon.x == j && pokemon.y == i
    }
    if (selectA.x == j && selectA.y == i){
        return AnyView(Image("\(Table[i][j])")
            .scaleEffect(showAnimation ? 1.5 : 1)
        )
    }else if(inPath){
        if ((path[0].x == j && path[0].y == i) || (path[path.count-1].x == j && path[path.count-1].y == i)){
            return AnyView(Image("\(Table[i][j])")
                .scaleEffect(showAnimationB ? 1.5 : 1)
                .opacity(showAnimationB ? 0 : 1)
            )
        }
        return AnyView(Image("星星")
            .scaleEffect(showAnimationB ? 1.5 : 1)
            .opacity(showAnimationB ? 0 : 1)
        )
    }
    else if((tipsA.x == j && tipsA.y == i ) || (tipsB.x == j && tipsB.y == i )){
        return AnyView(Image("\(Table[i][j])").border(Color.red,width: 3))
    }else{
        return AnyView(Image("\(Table[i][j])"))
    }
}
struct GameView: View{ //遊戲介面
    @State var Table = pokemon2DTable
    @State var showAnimation = false
    @State var showAnimationB = false
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
                        for item in path{
                            self.Table[item.y!][item.x!] = "無"
                        }
                        (self.tipsA , self.tipsB) = findTips(Table: self.Table)
                        if (self.tipsA.name != nil && self.tipsB.name != nil){
                            tipsTimes -= 1
                            path = []
                        }else{
                            print("找不到解")
                        }
                    }
                }){
                    Image("tips").foregroundColor(Color.green)
                }
                Text("提示:")
                    .font(.system(size:32))
                    .foregroundColor(Color.white)
                Text("\(tipsTimes)")
                    .font(.system(size: 32))
                    .foregroundColor(Color.white)
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
                    .foregroundColor(Color.white)
                Text("\(refreshTimes)")
                    .font(.system(size: 32))
                    .foregroundColor(Color.white)
                
                
                Text("分數:")
                    .font(.system(size: 32))
                    .foregroundColor(Color.white)
                Text("\(score)")
                    .fixedSize()
                    .foregroundColor(Color.white)
                    .font(.system(size: 32))
                    .frame(width:100)
                
            }.frame(minWidth:0,maxWidth: .infinity)//.background(Color.yellow)
            HStack{
                Spacer()//左側
                VStack{//中間位置
                    ForEach(0...tableHeight-1,id:\.self){ i in
                        HStack{
                            ForEach(0...tableWidth-1,id:\.self){ j in
                                Button(action:{
                                    //Button Action
                                    if (self.Table[i][j] == "無" || self.Table[i][j] == "星星"){
                                        self.selectA = Pokemon()
                                        self.selectB = Pokemon()
                                    }else{
                                        if (self.selectA.name != nil){
                                            //如果A可夢已經被選取則設定B可夢
                                            self.selectB.name = self.Table[i][j]
                                            self.selectB.x = j
                                            self.selectB.y = i
                                            self.showAnimation = false
                                            self.showAnimationB = false
                                            if (self.selectA.name == self.selectB.name && (self.selectA.x != self.selectB.x || self.selectA.y != self.selectB.y) ){//名字相同且不同位置
                                                path = []
                                                if(findpath(nodeX:self.selectA.x!,nodeY:self.selectA.y!,destinationX:self.selectB.x!,destinationY:self.selectB.y!,Table:self.Table)){
                                                    //如果有找到連接之路徑則顯示路徑
//                                                    for item in path{
//                                                        self.Table[item.y!][item.x!] = "星星"
//                                                    }
                                                    withAnimation(Animation.linear(duration: 0.5)){
                                                        self.showAnimationB = true
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
                                            path = []
                                            self.tipsA = Pokemon()
                                            self.tipsB = Pokemon()
                                            playSound(sound: "select")
                                            withAnimation(Animation.linear(duration: 0.2)){
                                                self.showAnimation = true
                                            }
                                        }
                                    }
                                    //Button Action
                                }){
                                    //ButtonStyle
                                    getImage(selectA: self.selectA,tipsA: self.tipsA, tipsB: self.tipsB, j: j, i: i, Table: self.Table,showAnimation:self.showAnimation,showAnimationB:self.showAnimationB)
                                    }.buttonStyle(PlainButtonStyle())//避免按鈕顏色覆蓋圖片
                                    .onAppear(perform:{
                                       

                                    })
                            }
                        }
                    }
                }
                Spacer()//右側
            }
            Spacer()
        }.background(Color.black.opacity(0.3))
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewLayout(.fixed(width:896,height:414))
    }
}
