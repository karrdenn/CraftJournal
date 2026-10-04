import SwiftUI

struct EntryDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var entry: CraftEntry
    @State private var showingEdit = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let data = entry.photo,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()
                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                if let location = entry.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let date = entry.date {
                    Text(date, style: .date)
                }
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEntryView(entry: entry)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
