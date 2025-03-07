//
//  FjordSettingVC.swift
//  FrozenFjords
//
//  Created by SunTory on 2025/3/7.
//

import UIKit

class FjordSettingVC: UIViewController {
    //MARK: - Declare IBOutlets
    
    
    //MARK: - Declare Variables
    
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Functions
    
    
    //MARK: - Declare IBAction
    
    @IBAction func btnShareApp(_ sender: Any) {
        let textToShare = "Check out Frozen Fjords app!"
        
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
}

//MARK: - Datasource and Delegate Methods
