//
//  ContentView.swift
//  TCA_Coordinator_Example
//
//  Created by LS-MAC-00213 on 2023/08/14.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct CoordinatorView: View {
    let store: StoreOf<Coordinator>
    
    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) { screen in
                switch screen {
                case .home:
                    CaseLet(
                        /Screen.State.home,
                         action: Screen.Action.home,
                         then: HomeView.init
                    )
                case .numberList:
                    CaseLet(
                        /Screen.State.numberList,
                         action: Screen.Action.numberList,
                         then: NumberListView.init
                    )
                case .numberDetail:
                    CaseLet(
                        /Screen.State.numberDetail,
                         action: Screen.Action.numberDetail,
                         then: NumberDetailView.init
                    )
                }
            }
        }
    }
}
