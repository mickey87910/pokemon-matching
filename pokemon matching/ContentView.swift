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
var pokemon1DTable:[Pokemon] = []
var pokemon2DTable:[[Pokemon]] = []
var path:[Pokemon] = [] //兩者路徑
var tableWidth = 12
var tableHeight = 6
var score = 0 //分數
var level = "" //難易度
var refreshTimes = 30 //洗牌次數
var tipsTimes = 30 //提示次數
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
func Win(Table:[[Pokemon]])->Bool{
    var Table = Table
    for item in path{
        Table[item.y!][item.x!].name = "無"
    }
    for i in Table{
        for item in i {
            if (item.name != "無"){
                    return false
            }
        }
    }
    return true
}
func GameStart(){
    //取出n*n的寶可夢
    pokemon1DTable = []
    pokemon2DTable = []
    path = []
    score = 0
    for _ in 0...tableWidth*tableHeight/2-1 {
        if let pokemonName = pokemonList.randomElement(){
            //寶可夢兩個同種類為一組
            pokemon1DTable.append(Pokemon(name:pokemonName))
            pokemon1DTable.append(Pokemon(name:pokemonName))
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
func shuffleTable(table:[[Pokemon]])-> [[Pokemon]]{
    var tmpTable:[Pokemon] = []
    var newTable:[[Pokemon]] = []
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
func findTips(Table:[[Pokemon]])->(Pokemon,Pokemon){
    var selectA = Pokemon()
    var selectB = Pokemon()
    for i in 0...tableHeight-1{
        for j in 0...tableWidth-1{
            if(Table[i][j].name != "無"){
                selectA.name = Table[i][j].name
                selectA.x = j
                selectA.y = i
                for k in 0...tableHeight-1{
                    for m in 0...tableWidth-1{
                        if (selectA.name == Table[k][m].name && (i != k || j != m) ){
                            selectB.name = Table[k][m].name
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
func findpath(nodeX:Int,nodeY:Int,destinationX:Int,destinationY:Int,Table:[[Pokemon]],nodes:[Pokemon] = [],times:Int = 0,direction:String = "NONE")->Bool{
    //初始化參數 & let to var
    var nodes = nodes
    var flag = false
    var directionList:[String] = []
    var node = Pokemon()
    node.name = "無"
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
        //將當前 node 加入 nodes 陣列
        nodes.append(node)
        if (nodeX == destinationX && nodeY == destinationY){
            //如果當前這個位置抵達目的地
            nodes[nodes.count-1].direction = "tail"
            path = nodes
            return true
        }else if(Table[nodeY][nodeX].name != "無" && direction != "NONE"){
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
                        nodes[nodes.count-1].direction = getDirectionNumber(oldDirection: direction, newDirection: directionList[i],directionChanged: false)
                        flag = findpath(nodeX: nodeX+x, nodeY: nodeY+y, destinationX: destinationX, destinationY: destinationY, Table: Table, nodes: nodes, times: times, direction: directionList[i])
                    }else{
                        //如果將行走方向與原方向不同代表轉彎
                        nodes[nodes.count-1].direction = getDirectionNumber(oldDirection: direction, newDirection: directionList[i],directionChanged: true)
                        flag = findpath(nodeX: nodeX+x, nodeY: nodeY+y, destinationX: destinationX, destinationY: destinationY, Table: Table, nodes: nodes, times: times+1, direction: directionList[i])
                    }
                }
            }
        }
    }
    return flag
}
func getDirectionNumber(oldDirection : String , newDirection : String , directionChanged : Bool)->String?{
    if (directionChanged == false){ //方向沒改
        if ((oldDirection == "RIGHT" || oldDirection == "LEFT") && (newDirection == "LEFT" || newDirection == "RIGHT")){ return "D456"}
        else if ((oldDirection == "UP" || oldDirection == "DOWN") && (newDirection == "DOWN" || newDirection == "UP")){ return "D258"}
        else{ return "head"}
    }else{ //方向變更
        if ((oldDirection == "RIGHT" && newDirection == "UP") || (oldDirection == "DOWN" && newDirection == "LEFT")){ return "D236"}//右to上 下to左
        else if ((oldDirection == "UP" && newDirection == "LEFT") || (oldDirection == "RIGHT" && newDirection == "DOWN")){ return "D698"}//上to左 右to下
        else if ((oldDirection == "UP" && newDirection == "RIGHT") || (oldDirection == "LEFT" && newDirection == "DOWN")){ return "D478"}//上to右 左to下
        else if ((oldDirection == "DOWN" && newDirection == "RIGHT") || (oldDirection == "LEFT" && newDirection == "UP")){ return "D214"}//左to上 //下to右
        
    }
    return nil
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
    var direction:String?
}
struct ContentView: View { //主畫面
    @State var showGameView : Bool = false //切換頁面判斷
    @State var showSetting : Bool = false //顯示遊戲設定
    @State var showIntroduction : Bool = false //顯示說明
    @State var showAnimation : Bool  = false
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
                            self.showAnimation = false
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
                            withAnimation{
                                self.showAnimation.toggle()
                            }
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
                            withAnimation{
                                self.showAnimation.toggle()
                            }
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
                                self.showAnimation = false
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
                                .padding([.top,.bottom],10)
                            Text("兩隻寶可夢間有路徑，並轉折兩次以內即可消除")
                            Image("intro1").resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 230, height: 70)
                            Image("intro2").resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 230, height: 70)
                            Text("成功消除可延長5秒，連續消除可獲得分數加成")
                                .padding([.bottom],10)
                            Text("成功消除所有寶可夢即可獲勝")
                                .padding([.bottom],10)
                            Button(action:{
                                self.showIntroduction = false
                                self.showAnimation = false
                                playSound(sound: "press")
                            }){
                                Text("Close").padding()
                                    .background(Color.white)
                                    .font(.system(size: 20))
                                    .border(Color.blue,width:3)
                                    .cornerRadius(8)
                            }
                        }
                    }.frame(width: self.showAnimation ? UIScreen.main.bounds.width/2 : 0, height: self.showAnimation ? UIScreen.main.bounds.height*17/18 : 0, alignment: .center)
                        .background(Color.white)
                        .opacity(self.showAnimation ? 1 : 0)
                        .cornerRadius(8)
                    
                }.frame(minWidth:0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity).edgesIgnoringSafeArea(.all).background(Color.black.opacity(0.5))
            }
        }.frame(minWidth:0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity).edgesIgnoringSafeArea(.all).background(Image("星空"))//.background(Color(red:187/255.0,green:255/255.0,blue:180/255.0))
    }
}
func getImage(selectA:Pokemon,tipsA:Pokemon,tipsB:Pokemon,j:Int,i:Int,Table:[[Pokemon]],showAnimation:Bool,showAnimationB:Bool)->AnyView{
    let inPath = path.contains{ (pokemon) -> Bool in
        //查看當前節點是否為路徑
        return pokemon.x == j && pokemon.y == i
    }
    var pathPokemon = Pokemon()
    for pokemon in path {
        if (pokemon.x == j && pokemon.y == i){
            pathPokemon = pokemon
        }
    }
    if (selectA.x == j && selectA.y == i){
        //放大選擇的寶可夢
        return AnyView(Image("\(Table[i][j].name!)")
            .scaleEffect(showAnimation ? 1.5 : 1)
        )
    }else if(inPath){
        if ((path[0].x == j && path[0].y == i) || (path[path.count-1].x == j && path[path.count-1].y == i)){
            //path頭尾動畫
            return AnyView(Image("\(Table[i][j].name!)")
                .scaleEffect(showAnimationB ? 1.5 : 1)
                .opacity(showAnimationB ? 0 : 1)
            )
        }else{
            //path路徑動畫
            return AnyView(Image("\(pathPokemon.direction!)")
                .scaleEffect(1.2)
                .opacity(showAnimationB ? 0 : 1))
            
        }
    }
    else if((tipsA.x == j && tipsA.y == i ) || (tipsB.x == j && tipsB.y == i )){
        //圈出提示的位置
        return AnyView(Image("\(Table[i][j].name!)").border(Color.red,width: 3))
    }else{
        return AnyView(Image("\(Table[i][j].name!)"))
    }
}

struct GameView: View{ //遊戲介面
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() //倒數計時Timer
    @State var Table = pokemon2DTable
    @State var showAnimation = false
    @State var showAnimationB = false
    @State var showAttention = false
    @State var showGrade = false
    @State var selectA = Pokemon()
    @State var selectB = Pokemon()
    @State var tipsA = Pokemon()
    @State var tipsB = Pokemon()
    @State var gameTime = 10 //遊戲時間
    @State private var isActive = true
    @State var progressValue: Float = 1.0
    var body: some View{
        ZStack{
            VStack{
                HStack{
                    Button(action:{
                        self.showAttention = true
                        self.isActive = false
                    }){
                        Image("close").foregroundColor(Color.red)
                        Text("時間:")
                            .font(.system(size:32))
                            .foregroundColor(Color.white)
                        
                        ProgressBar(progress: self.$progressValue)
                        .frame(width: 45.0, height: 45.0)
                        .padding(10.0)
                        
                        Text("\(gameTime)")   //倒數計時
                            .font(.system(size:32))
                            .foregroundColor(Color.white)
                            .onReceive(timer) { _ in
                                if (self.gameTime > 0) {
                                    self.gameTime -= 1
                                    self.progressValue -= 100/18000
                                }else{
                                    self.showGrade = true
                                }
                            }
                    }
                    
                    Spacer()
                    
                    Button(action:{
                        //do 提示
                        if (tipsTimes > 0) {
                            playSound(sound: "spell")
                            for item in path{
                                self.Table[item.y!][item.x!].name = "無"
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
                                self.Table[item.y!][item.x!].name = "無"
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
                                        if (self.Table[i][j].name == "無" || self.Table[i][j].name == "星星"){
                                            self.selectA = Pokemon()
                                            self.selectB = Pokemon()
                                        }else{
                                            if (self.selectA.name != nil){
                                                //如果A可夢已經被選取則設定B可夢
                                                self.selectB.name = self.Table[i][j].name
                                                self.selectB.x = j
                                                self.selectB.y = i
                                                self.showAnimation = false
                                                self.showAnimationB = false
                                                if (self.selectA.name == self.selectB.name && (self.selectA.x != self.selectB.x || self.selectA.y != self.selectB.y) ){//名字相同且不同位置
                                                    path = []
                                                    if(findpath(nodeX:self.selectA.x!,nodeY:self.selectA.y!,destinationX:self.selectB.x!,destinationY:self.selectB.y!,Table:self.Table)){
                                                        withAnimation(Animation.linear(duration: 0.5)){
                                                            self.showAnimationB = true
                                                        }
                                                        print(Win(Table:self.Table))
                                                        self.showGrade = Win(Table:self.Table)
                                                        score = score + 100
                                                        
                                                        if (self.gameTime + 5 >= 180){   //時間規則：成功配對加五秒（上限180秒）
                                                            self.gameTime = 180
                                                            self.progressValue = 1.0
                                                        }else{
                                                            self.gameTime += 5
                                                            self.progressValue += 500/18000
                                                        }
                                                        
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
                                                self.selectA.name = self.Table[i][j].name
                                                self.selectA.x = j
                                                self.selectA.y = i
                                                for item in path{
                                                    self.Table[item.y!][item.x!].name = "無"
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
                                }
                            }
                        }
                    }
                    Spacer()//右側
                }
                Spacer()
            }.background(Color.black.opacity(0.3))
             

            if(self.showAttention){
                ZStack{
                    VStack{
                        //遊戲重新視窗
                            Text("是否要重新開始")
                                .font(.largeTitle)
                                .padding(10)
                            HStack{
                                Button(action:{
                                    self.showAttention = false
                                    GameStart()
                                    self.Table = pokemon2DTable
                                    self.gameTime = 180   //重設時將倒數恢復為180
                                    self.progressValue = 1.0
                                    playSound(sound: "press")
                                }){
                                    Text("是")
                                        .padding()
                                        .background(Color.white)
                                        .font(.system(size: 26))
                                        .border(Color.blue,width:3)
                                        .cornerRadius(8)
                                }.padding(10)
                                
                                Button(action:{
                                    self.showAttention = false
                                    playSound(sound: "press")
                                }){
                                    Text("否")
                                        .padding()
                                        .background(Color.white)
                                        .font(.system(size: 26))
                                        .border(Color.blue,width:3)
                                        .cornerRadius(8)
                                }.padding(10)
                            }
                        
                    }.frame(width: self.showAttention ? UIScreen.main.bounds.width/2 : 0, height: self.showAttention ? UIScreen.main.bounds.height/2 : 0, alignment: .center)
                        .background(Color.white)
                        .opacity(self.showAttention ? 1 : 0)
                        .cornerRadius(8)
                    
                }.frame(minWidth:0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity).edgesIgnoringSafeArea(.all).background(Color.black.opacity(0.5))
            }
            
            if(showGrade){
                ZStack{
                    VStack{
                         //遊戲說明視窗
                        if(Win(Table:self.Table)){
                            Text("過關！")
                                .font(.largeTitle)
                                .padding([.top,.bottom],10)
                            Button(action:{
                                self.showGrade = false
                                playSound(sound: "press")
                            }){
                                Text("Continue").padding()
                                    .background(Color.white)
                                    .font(.system(size: 20))
                                    .border(Color.blue,width:3)
                                    .cornerRadius(8)
                            }
                        }else{
                            Text("Gamer Over")
                                .font(.largeTitle)
                                .padding([.top,.bottom],10)
                            Button(action:{
                                self.showGrade = false
                                GameStart()
                                self.Table = pokemon2DTable
                                self.gameTime = 180   //重設時將倒數恢復為180
                                self.progressValue = 1.0
                                playSound(sound: "press")
                            }){
                                Text("Restart").padding()
                                    .background(Color.white)
                                    .font(.system(size: 20))
                                    .border(Color.blue,width:3)
                                    .cornerRadius(8)
                            }
                        }
                            
                    }.frame(width: self.showGrade ? UIScreen.main.bounds.width/3 : 0, height: self.showGrade ? UIScreen.main.bounds.height/2 : 0, alignment: .center)
                        .background(Color.white)
                        .opacity(self.showGrade ? 1 : 0)
                        .cornerRadius(8)
                    
                }.frame(minWidth:0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity).edgesIgnoringSafeArea(.all).background(Color.black.opacity(0.5))
            }
            
        }
        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewLayout(.fixed(width:896,height:414))
    }
}
//計時
struct ProgressBar: View {
    @Binding var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .foregroundColor(Color.yellow)
                .opacity(0.3)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.yellow)
                
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)

            
        }
    }
}
//遊戲說明
//遊戲設定
//結算的視窗
