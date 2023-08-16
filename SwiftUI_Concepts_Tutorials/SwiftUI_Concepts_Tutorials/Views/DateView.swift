//
//  DateView.swift
//  SwiftUI_Concepts_Tutorials
//
//  Created by LS-MAC-00213 on 2023/08/16.
//

import SwiftUI

struct DateView: View {
    let date: Date
    
    var weekday: String {
        date.formatted(Date.FormatStyle().weekday(.abbreviated)).localizedUppercase
    }
    
    var day: String {
        date.formatted(Date.FormatStyle().day())
    }
    
    var body: some View {
        HStack {
            Text(weekday)
            Text(day)
        }
        .font(.headline)
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        DateView(date: .now)
    }
}
