//
//  File.swift
//  
//
//  Created by Haadhya on 19/12/23.
//

import Foundation
import Security
import Alamofire

class PinnedCertificatesTrustEvaluator: ServerTrustEvaluating {
    let certificates: [SecCertificate]

    init(certificates: [SecCertificate]) {
        self.certificates = certificates
    }

    func evaluate(_ serverTrust: SecTrust, forHost host: String) throws {
        var serverCertFound = false

        for i in 0..<SecTrustGetCertificateCount(serverTrust) {
            let serverCert = SecTrustGetCertificateAtIndex(serverTrust, i)
            
            if certificates.contains(serverCert!) {
                serverCertFound = true
                break
            }
        }

        guard serverCertFound else {
            throw MyCustomError.sslPinningFailed
        }
    }
}

enum MyCustomError: Error {
    case sslPinningFailed
}
