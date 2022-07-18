//
//  ContentView.swift
//  Ebi
//
//  Created by macboy on 2022/07/18.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteView(scene: GameScene(), debugOptions: [.showsFPS, .showsDrawCount])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
