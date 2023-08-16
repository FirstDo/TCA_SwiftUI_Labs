//
//  IfElseTrain.swift
//  SwiftUI_Concepts_Tutorials
//
//  Created by LS-MAC-00213 on 2023/08/16.
//

import SwiftUI

struct IfElseTrain: View {
    let longerTrain: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "train.side.rear.car")
                if longerTrain {
                    Image(systemName: "train.side.middle.car")
                }
                Image(systemName: "train.side.front.car")
            }
            Divider()
        }
    }
}

struct IfElseTrain_Previews: PreviewProvider {
    static var previews: some View {
        IfElseTrain(longerTrain: true)
        IfElseTrain(longerTrain: false)
    }
}
