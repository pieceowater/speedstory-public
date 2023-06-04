//
//  AdMobViewModel.swift
//  speedstory
//
//  Created by yury mid on 04.06.2023.
//

import Foundation
import GoogleMobileAds
import UIKit

final class GoogleAd: NSObject, GADFullScreenContentDelegate {

    var rewardedAd: GADRewardedAd?

    var rewardFunction: (() -> Void)? = nil

    override init() {
        super.init()
    }

    func LoadRewarded() {
        let adUnitID = "ca-app-pub-9943198553187181/1986803150"
        let request = GADRequest()
        
        GADRewardedAd.load(withAdUnitID: adUnitID, request: request) { (ad, error) in
            if let error = error {
                print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                return
            }
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }


    func showAd(rewardFunction: @escaping () -> Void){
        LoadRewarded()
        let root = UIApplication.shared.windows.first?.rootViewController
        if let ad = rewardedAd {
              ad.present(fromRootViewController: root!,
                       userDidEarnRewardHandler: {
                            let reward = ad.adReward
                            rewardFunction()
                       }
              )
          } else {
            print("Ad wasn't ready")
          }
    }

    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        if let rf = rewardFunction {
            rf()
        }
    }
}
