import SwiftUI

struct BookCardView: View {
    let book: Book
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: book.book_image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let img):
                    img.resizable()
                       .scaledToFill()
                case .failure(_):
                    Color.gray
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(10)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.6)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(width: width, height: height)
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)          // prevent big overflow
                    .truncationMode(.tail)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(8)
        }
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}
