//
//  StarRating.swift
//  SwiftUI_Concepts_Tutorials
//
//  Created by LS-MAC-00213 on 2023/08/16.
//

import SwiftUI

struct StarRating: View {
    @Binding var rating: Int
    private let maxRating = 5
    
    var body: some View {
        HStack {
            ForEach(1..<maxRating + 1, id: \.self) { value in
                Image(systemName: "star")
                    .symbolVariant(value <= rating ? .fill : .none)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        if value != rating {
                            rating = value
                        } else {
                            rating = 0
                        }
                    }
            }
        }
    }
}

struct StarRating_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StarRating(rating: .constant(0))
            StarRating(rating: .constant(1))
            StarRating(rating: .constant(2))
            StarRating(rating: .constant(3))
            StarRating(rating: .constant(4))
        }
    }
}
