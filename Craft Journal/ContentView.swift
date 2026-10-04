//
//  ContentView.swift
//  Zorig Craft Journal
//

import SwiftUI
import CoreData

enum SortOption: String, CaseIterable, Identifiable {
    case newest = "Newest First"
    case oldest = "Oldest First"
    case title = "A–Z"

    var id: String { rawValue }

    var descriptors: [NSSortDescriptor] {
        switch self {
        case .newest:
            return [NSSortDescriptor(keyPath: \CraftEntry.date, ascending: false)]
        case .oldest:
            return [NSSortDescriptor(keyPath: \CraftEntry.date, ascending: true)]
        case .title:
            return [NSSortDescriptor(keyPath: \CraftEntry.title, ascending: true)]
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CraftEntry.date, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<CraftEntry>

    @State private var showingAddEntry = false
    @State private var searchText = ""
    @State private var sortOption: SortOption = .newest

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    if searchText.isEmpty {
                        ContentUnavailableView(
                            "No Journal Entries",
                            systemImage: "book.closed",
                            description: Text("Add your first craft journal entry by tapping the + button.")
                        )
                    } else {
                        ContentUnavailableView.search(text: searchText)
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text(entries.count == 1 ? "1 entry" : "\(entries.count) entries")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        List {
                            ForEach(entries) { entry in
                                NavigationLink(destination: EntryDetailView(entry: entry)) {
                                    EntryRow(entry: entry)
                                }
                            }
                            .onDelete(perform: deleteEntries)
                        }
                    }
                }
            }
            .navigationTitle("Craft Journal")
            .searchable(text: $searchText, prompt: "Search by title")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort by", selection: $sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .onChange(of: searchText) {
                updateSearch()
            }
            .onChange(of: sortOption) {
                entries.nsSortDescriptors = sortOption.descriptors
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func updateSearch() {
        if searchText.isEmpty {
            entries.nsPredicate = nil
        } else {
            entries.nsPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        }
    }

    private func deleteEntries(offsets: IndexSet) {
        offsets.map { entries[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Could not delete: \(error)")
        }
    }
}

struct EntryRow: View {
    @ObservedObject var entry: CraftEntry

    var body: some View {
        HStack {
            if let data = entry.photo, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading) {
                Text(entry.title ?? "Untitled")
                    .font(.headline)
                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let location = entry.location, !location.isEmpty {
                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
