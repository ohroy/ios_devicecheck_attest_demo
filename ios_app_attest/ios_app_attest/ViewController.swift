import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("hello , let's do it! ")
        
        Task {
            if let attest = AppAttest(){
                print("now let start get key")
                print(attest.keyIdentifier())
                print("now let start verify key")
                await attest.preAttestation()
            }
        }
    }
}

