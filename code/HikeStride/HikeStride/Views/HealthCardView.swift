//
//  HealthCardView.swift
//  HikeStride
//
//  Created by Janindu Dissanayake on 2024-06-10.
//

import SwiftUI

struct HealthCardView: View {
    let title: String
    let value: String
    let image: String
    let iconColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Image(systemName: image)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
                
                Spacer().frame(width: 20)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: geometry.size.width / 2, alignment: .leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer().frame(height: 5)
                    
                    Text(value)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.primary)
                }
            }
            .padding([.horizontal, .vertical])
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            
        }
        .frame(height: 100)
    }
        
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HealthCardView(title: "Steps", value: "1234", image: "shoeprints.fill", iconColor: .orange)
                .previewLayout(.sizeThatFits)
                .padding()
            HealthCardView(title: "Very Long Title That Exceeds The Width", value: "5678", image: "flame.fill", iconColor: .red)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
