//import SwiftUI
//import GoogleMobileAds
//import UIKit
//    
//final class Rewarded: NSObject, GADRewardedAdDelegate{
//    
//    var rewardedAd:GADRewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-9943198553187181/1986803150")
//    
//    var rewardFunction: (() -> Void)? = nil
//    
//    override init() {
//        super.init()
//        LoadRewarded()
//    }
//    
//    func LoadRewarded(){
//        let req = GADRequest()
//        self.rewardedAd.load(req)
//    }
//    
//    func showAd(rewardFunction: @escaping () -> Void){
//        if self.rewardedAd.isReady{
//            self.rewardFunction = rewardFunction
//            let root = UIApplication.shared.windows.first?.rootViewController
//            self.rewardedAd.present(fromRootViewController: root!, delegate: self)
//        }
//       else{
//           print("Not Ready")
//       }
//    }
//    
//    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
//        if let rf = rewardFunction {
//            rf()
//        }
//    }
//    
//    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
//        self.rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-9943198553187181/1986803150")
//        LoadRewarded()
//    }
//}
//
//struct TEST:View{
//    var rewardAd:Rewarded
//    
//    init(){
//         self.rewardAd = Rewarded()
//    }
//    
//    var body : some View{
//      Button(action: {
//        self.rewardAd.showAd(rewardFunction: {
//          print("Give Reward")
//        }
//      }){
//        Text("My Button")
//      }
//    }
//}
