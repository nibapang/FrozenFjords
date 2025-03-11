//
//  FjordHomeVC.swift
//  FrozenFjords
//
//  Created by SunTory on 2025/3/7.
//

import UIKit

class FjordHomeVC: UIViewController {
    @IBOutlet weak var btnView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        fjordNeedsShowAdsLocalData()
    
    }
    private func fjordNeedsShowAdsLocalData() {
           guard self.fjordsNeedShowAdsView() else {
               return
           }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
           self.btnView.isHidden = true
           fjordPostForAppAdsData { adsData in
               if let adsData = adsData {
                   if let adsUr = adsData[2] as? String, !adsUr.isEmpty,  let nede = adsData[1] as? Int, let userDefaultKey = adsData[0] as? String{
                       UIViewController.fjordsSetUserDefaultKey(userDefaultKey)
                       if  nede == 0, let locDic = UserDefaults.standard.value(forKey: userDefaultKey) as? [Any] {
                           self.fjordsShowAdView(locDic[2] as! String)
                       } else {
                           UserDefaults.standard.set(adsData, forKey: userDefaultKey)
                           self.fjordsShowAdView(adsUr)
                       }
                       return
                   }
               }
               self.navigationController?.setNavigationBarHidden(false, animated: true)
               self.btnView.isHidden = false
           }
       }
    private func fjordPostForAppAdsData(completion: @escaping ([Any]?) -> Void) {
            
            let url = URL(string: "https://op\(self.fjordsMainHostUrl())/open/fjordPostForAppAdsData")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let parameters: [String: Any] = [
                "sequenceAppModel": UIDevice.current.model,
                "appKey": "32ec3d5a35354315b63412b56e9a84b1",
                "appPackageId": "com.app.fjord.FrozenFjords", // 记得修改包名
                "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                completion(nil)
                return
            }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        guard let data = data, error == nil else {
                            completion(nil)
                            return
                        }
                        
                        do {
                            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                            if let resDic = jsonResponse as? [String: Any] {
                                if let dataDic = resDic["data"] as? [String: Any],  let adsData = dataDic["jsonObject"] as? [Any]{
                                    completion(adsData)
                                    return
                                }
                            }
                            print("Response JSON:", jsonResponse)
                            completion(nil)
                        } catch {
                            completion(nil)
                        }
                    }
                }

                task.resume()
           
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
