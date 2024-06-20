//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 19/06/2024.
//

import Foundation
import Combine

class AutoRelease {
  static let shared = AutoRelease()
  
  enum Keys {
    static let cache = "ReleaseCache"
  }
  
  @Published private(set) var isRelease: Bool?
  private var nowVersion: Double = 0.0
  private var releaseVersion: Double = 0.0
  private var didCheck = false
  private let timeout = 10.0
  
  init() {
    fetch()
    check()
  }
}

extension AutoRelease {
  private func check() {
    guard let nowVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? NSString else {
      // Không lấy được version hiện tại.
      change(isRelease: true)
      return
    }
    self.nowVersion = nowVersionString.doubleValue
    
    if nowVersion <= releaseVersion {
      // Version hiện tại đã release, đã được cache.
      change(isRelease: true)
    } else {
      guard let bundleId = Bundle.main.bundleIdentifier else {
        // // Không lấy được bundleId.
        change(isRelease: true)
        return
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
        guard let self else {
          return
        }
        // Quá thời gian timeout chưa trả về, mặc định trạng thái bật.
        change(isRelease: true)
      }
      Task {
        // Tìm version đang release trên AppStore.
        await load(bundleId: bundleId)
      }
    }
  }
  
  private func load(bundleId: String) async {
    do {
      let releaseResponse: ReleaseResponse = try await APIService().request(from: .releaseVersion(bundleId: bundleId))
      guard let result = releaseResponse.results.first else {
        // Hiện tại chưa có version release nào.
        change(isRelease: false)
        return
      }
      let releaseVersionString = result.version as NSString
      let releaseVersion = releaseVersionString.doubleValue
      print("[AdMobManager] Release version:", releaseVersion)
      
      if nowVersion <= releaseVersion {
        // Version hiện tại đã release. Cache version.
        update(releaseVersion)
        change(isRelease: true)
      } else {
        // Version hiện tại chưa release.
        change(isRelease: false)
      }
    } catch {
      // Lỗi không load được version release, mặc định trạng thái bật.
      change(isRelease: true)
    }
  }
  
  private func change(isRelease: Bool) {
    guard !didCheck else {
      return
    }
    self.didCheck = true
    self.isRelease = isRelease
  }
  
  private func fetch() {
    self.releaseVersion = UserDefaults.standard.double(forKey: Keys.cache)
  }
  
  private func update(_ releaseVersion: Double) {
    UserDefaults.standard.set(releaseVersion, forKey: Keys.cache)
    fetch()
  }
}
