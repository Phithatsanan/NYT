import SwiftUI

struct NYTCardView: View {
    let imageURL: URL?
    let title: String
    let subtitle: String
    /// We fix the card’s width and height so it won’t grow.
    let width: CGFloat = 280
    let height: CGFloat = 140
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.2)
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure(_):
                    Color.gray.opacity(0.4)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(12)
            
            // A gradient at bottom
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.6)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(width: width, height: height)
            .cornerRadius(12)
            
            // Title + Subtitle with line limits
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)            // up to 2 lines
                    .truncationMode(.tail)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)            // up to 2 lines
                    .truncationMode(.tail)
            }
            .padding()
        }
        .frame(width: width, height: height) // ensures the total card doesn't grow
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
