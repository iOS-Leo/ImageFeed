//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 17.05.2026.
//

import Foundation
import WebKit

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
  
   private init() { }

   func logout() {
      cleanCookies()
      clearServicesData()
      switchToSplashViewController()
   }

   private func cleanCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
   
   private func clearServicesData() {
      OAuth2TokenStorage.shared.token = nil
      
      ProfileService.shared.clearProfileData()
      ProfileImageService.shared.clearAvatarData()
      ImagesListService.shared.clearPhotosData()
   }
   
   private func switchToSplashViewController() {
      guard let window = UIApplication.shared.connectedScenes
         .compactMap({ $0 as? UIWindowScene })
         .flatMap({ $0.windows })
         .first(where: { $0.isKeyWindow }) else { return }
      
      let splashViewController = SplashViewController()
      window.rootViewController = splashViewController
   }
}
