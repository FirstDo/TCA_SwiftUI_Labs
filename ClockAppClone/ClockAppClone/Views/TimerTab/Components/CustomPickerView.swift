import UIKit
import SwiftUI

struct CustomPicker: UIViewRepresentable {
  let items: [[Int]]
  @Binding var selections: [Int]
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
  
  func makeUIView(context: Context) -> UIPickerView {
    let picker = UIPickerView(frame: .zero)
    picker.dataSource = context.coordinator
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIView(_ picker: UIPickerView, context: Context) {
    selections.enumerated().forEach { (index, value) in
      picker.selectRow(value, inComponent: index, animated: false)
    }
  }
  
  class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    var parent: CustomPicker
    
    init(_ parent: CustomPicker) {
      self.parent = parent
    }
   
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return parent.items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return parent.items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return String(describing: parent.items[component][row])
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
      return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      parent.selections[component] = parent.items[component][row]
    }
  }
}

struct CustomPicker_Previews: PreviewProvider {
  static var previews: some View {
    CustomPicker(items: [Array(0...23), Array(0...59), Array(0...59)], selections: .constant([0, 15, 0]))
  }
}
