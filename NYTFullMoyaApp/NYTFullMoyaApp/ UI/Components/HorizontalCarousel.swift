import SwiftUI

struct HorizontalCarousel<Item: Identifiable>: View {
    let items: [Item]
    let imageURL: (Item) -> URL?
    let title: (Item) -> String
    let subtitle: (Item) -> String
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let onTap: (Item) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) { // reduce spacing from 16 to 12
                ForEach(items) { item in
                    Button {
                        onTap(item)
                    } label: {
                        NYTCardView(
                            imageURL: imageURL(item),
                            title: title(item),
                            subtitle: subtitle(item)
                        )
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical, 8)  // smaller vertical padding
        }
    }
}
