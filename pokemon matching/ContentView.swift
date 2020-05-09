//
//  ContentView.swift
//  pokemon matching
//
//  Created by mickey on 2020/5/8.
//  Copyright © 2020 mickey. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack{
            Text("寶可夢連連看")
                .bold()
                .font(.system(size: 48))
                .foregroundColor(.yellow)
                .padding()
            
            Button(action:{
                //要執行的內容
                print(123)
            }){
                //按鈕樣式設定
                Text("開始遊戲")
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
                    .padding()
                    
            }
        }.frame(minWidth:0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewLayout(.fixed(width:896,height:414))
    }
}
