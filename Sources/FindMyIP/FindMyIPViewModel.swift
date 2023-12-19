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
    @Published var showError = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchData() {
        isLoading = true
        
        // Load your certificate
        guard let certificatePath = Bundle.main.path(forResource: "github.com", ofType: "cer"),
              let certificateData = try? Data(contentsOf: URL(fileURLWithPath: certificatePath)),
              let certificate = SecCertificateCreateWithData(nil, certificateData as CFData)
        else {
            self.errorMessage = "Error loading certificate"
            self.showError = true
            return
        }
        
        // Configure ServerTrustManager with SSL pinning
        let serverTrustManager = ServerTrustManager(evaluators: [
            "jsonplaceholder.typicode.com": PinnedCertificatesTrustEvaluator(certificates: [certificate])
        ])
        
        // Configure Session with ServerTrustManager
        let session = Session(serverTrustManager: serverTrustManager)
        
        session.request("https://jsonplaceholder.typicode.com/posts")
            .validate()
            .publishDecodable(type: FIndMyIPModel.self)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }, receiveValue: { response in
                self.content = response.value
            })
            .store(in: &cancellables)
    }
    
    
}
