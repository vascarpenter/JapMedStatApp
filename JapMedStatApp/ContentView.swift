//
//  ContentView.swift
//  JapMedStatApp
//
//  Created by Namikare Gikoha on 2021/02/13.
//

import SwiftUI

struct ContentView: View
{
    @State private var inputText = ""
    var body: some View
    {
        VStack
        {
            Spacer()
            Button(action: {
                let dialog = NSOpenPanel()

                dialog.title = "Choose a SJIS file"
                dialog.showsResizeIndicator = true
                dialog.showsHiddenFiles = false
                dialog.allowsMultipleSelection = false
                dialog.canChooseDirectories = false

                if dialog.runModal() == NSApplication.ModalResponse.OK
                {
                    if let result = dialog.url
                    {
                        let text = try? String(contentsOfFile: result.path, encoding: String.Encoding.shiftJIS)
                        inputText = japmedstat(text: text ?? "")
                    }
                }
                else
                {
                    // User clicked on "Cancel"
                    return
                }

            })
            {
                Text("Open SJIS file...")
            }
            ScrollView
            {
                TextEditor(text: $inputText)
                    .disableAutocorrection(true)
                    .padding(.all, 8.0)
                    .frame(width: 700.0, height: 400.0)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
