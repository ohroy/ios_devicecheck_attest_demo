import DeviceCheck
import CryptoKit

final class AppAttest {
    private let keyName = "AppAttestKeyIdentifier"
    private let attestService = DCAppAttestService.shared
    private let userDefaults = UserDefaults.standard
    private var keyID: String? {
        didSet
        {
            print("🐝 Key ID:", keyID!)
        }
    }
    
    init?() {
        
        guard attestService.isSupported == true else {
            print("[!] Attest service not available:")
            return nil
        }
        
        
        guard let id = userDefaults.object(forKey:keyName) as? String else {
            attestService.generateKey { keyIdentifier, error in
                guard error == nil, keyIdentifier != nil else { return }
                self.keyID = keyIdentifier
                if self.keyID != nil {
                    print("🐝 Generated key")
                    self.userDefaults.set(self.keyID, forKey: self.keyName)
                }
                
            }
            return nil
        }
        keyID = id
        
        
    }
    
    func keyIdentifier() -> String {
        return ("🐝 Key Identifier: \(self.keyID ?? "Error in Key ID")")
    }

    // https://developer.apple.com/documentation/devicecheck/dcappattestservice/3573911-attestkey
    // A SHA256 hash of a unique, single-use data block that embeds a challenge from your server.

    func preAttestation() async -> Void {
        
        // MARK: get the Session ID from my server ( and not generate it locally )
        let randomSessionID = NSUUID().uuidString
        let challenge = randomSessionID.data(using: .utf8)!
        let hash = Data(SHA256.hash(data: challenge))
        
        /* invokes network call to Apple's attest service */
        print("🐝 Calling Apple servers")
        let  attestation = try? await attestService.attestKey(self.keyID!, clientDataHash: hash)
        guard attestation != nil else {
            print("attestation nil")
            return
        }
        print("your asttest object is:")
        print(attestation!.base64EncodedString())
        let assertion = try? await attestService.generateAssertion(self.keyID!, clientDataHash: hash)
        print("your assertion object is:")
        print(assertion!.base64EncodedString())
    }
}
