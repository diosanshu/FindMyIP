// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

@available(iOS 14.0, *)
public struct FindMyIP: View {
    @StateObject private var viewModel = FindMyIPViewModel()

    public init() {}
    public var body: some View {
        VStack {
            if let content = viewModel.content {
                Text(content.title)
                Text(content.body)

            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            } else {
                ProgressView("Loading...")
                    .onAppear(perform: {
                        viewModel.fetchData()
                    })
            }
        }
        .padding()
        .alert(isPresented: $viewModel.showError) {
                   Alert(
                       title: Text("Error"),
                       message: Text(viewModel.errorMessage ?? "Unknown error"),
                       dismissButton: .default(Text("OK"))
                   )
               }
    }
}
