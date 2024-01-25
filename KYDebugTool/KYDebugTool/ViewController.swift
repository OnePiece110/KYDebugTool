//
//  ViewController.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        LocationManager.shared.didUpdate = { [weak self] value in
//            self?.text.text = value
//        }
    }

    @IBOutlet var text: UILabel!

    @IBAction func successMocked() {
        let random: Int = .random(in: 1...5)
        let url = "https://reqres.in/api/users?page=\(random)"
        KYRequestManager.mockRequest(url: url)
    }

    @IBAction func failureRequest() {
        let url = "https://reqres.in/api/users/23"
        KYRequestManager.mockRequest(url: url)
    }

    @IBAction func seeLocation() {
//        LocationManager.shared.requestLocation()
    }

    @IBAction func crash() {
//        var index: Int?
//        print(index!)
//        let array = [1, 2, 3]
//        array[10]
        DispatchQueue.global().async {
            fatalError("batata")
        }
    }

}

