//
//  AddEntryView.swift
//  Zorig Craft Journal
//

import SwiftUI
import CoreData
import PhotosUI

struct AddEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    // nil = creating a new entry, non-nil = editing this entry
    var entry: CraftEntry?

    @State private var title: String
    @State private var craftType: String
    @State private var notes: String
    @State private var location: String
    @State private var image: UIImage?
    @State private var showingCamera = false
    @State private var selectedItem: PhotosPickerItem?

    init(entry: CraftEntry? = nil) {
        self.entry = entry
        _title = State(initialValue: entry?.title ?? "")
        _craftType = State(initialValue: entry?.craftType ?? crafts[0])
        _notes = State(initialValue: entry?.notes ?? "")
        _location = State(initialValue: entry?.location ?? "")
        if let data = entry?.photo {
            _image = State(initialValue: UIImage(data: data))
        } else {
            _image = State(initialValue: nil)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Picker("Craft", selection: $craftType) {
                    ForEach(crafts, id: \.self) { craft in
                        Text(craft)
                    }
                }
                TextField("Location", text: $location)
                Section("Photo") {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                    }
                    Button("Take Photo") {
                        showingCamera = true
                    }
                    .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        Label("Choose from Library", systemImage: "photo")
                    }
                }
                TextField("Notes", text: $notes, axis: .vertical)
            }
            .onChange(of: selectedItem) {
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        image = uiImage
                    }
                }
            }
            .navigationTitle(entry == nil ? "New Entry" : "Edit Entry")
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(image: $image)
                    .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveEntry() {
        // Edit: reuse the existing object. New: create one.
        let target = entry ?? CraftEntry(context: viewContext)

        if entry == nil {
            target.id = UUID()
            target.date = Date()
        }
        target.title = title
        target.craftType = craftType
        target.notes = notes
        target.location = location
        target.photo = image?.jpegData(compressionQuality: 0.7)

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not save: \(error)")
        }
    }
}
