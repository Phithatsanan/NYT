import SwiftUI

struct SectionHeader: View {
    let title: String
    let onSeeAll: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2).bold()
            Spacer()
            Button("See All") {
                onSeeAll()
            }
            .foregroundColor(.blue)
        }
    }
}
