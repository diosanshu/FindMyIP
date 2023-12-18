//
//  File.swift
//  
//
//  Created by Haadhya on 19/12/23.
//

import SwiftUI
import Combine
import Alamofire

@available(iOS 13.0, *)
public class FindMyIPViewModel: ObservableObject {
    @Published var content: FIndMyIPModel?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()

    func fetchData() {
        isLoading = true

        AF.request("https://ipapi.co/json/")
            .validate()
            .publishDecodable(type: FIndMyIPModel.self)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { response in
                self.content = response.value
            })
            .store(in: &cancellables)
    }
}
