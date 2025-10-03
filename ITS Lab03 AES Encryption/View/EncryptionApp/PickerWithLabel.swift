import SwiftUI

struct PickerWithLabel<Selection: RawRepresentable & Hashable & Identifiable>: View where Selection.RawValue == String {
    let label: String
    let selections: [Selection]
    @Binding var selection: Selection
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            
            Picker(selection: $selection) {
                ForEach(selections) { s in
                    Text(s.rawValue.uppercased())
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
        }
    }
}
