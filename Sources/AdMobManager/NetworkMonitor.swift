//
//  NetworkMonitor.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 04/04/2022.
//

import Foundation
import Network

@available(iOS 12.0, *)
final class NetworkMonitor {

  static let shared = NetworkMonitor()

  enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
  }

  private let queue = DispatchQueue.global()
  private let monitor: NWPathMonitor
  private var connectState = false
  private var connectionType: ConnectionType = .unknown

  init() {
    monitor = NWPathMonitor()
    startMonitoring()
  }

  func isConnected() -> Bool {
    return connectState
  }

  private func startMonitoring() {
    monitor.start(queue: queue)
    monitor.pathUpdateHandler = { [weak self] path in
      guard let self = self else {
        return
      }
      self.connectState = path.status == .satisfied
      self.setConnectionType(path)
    }
  }

  private func stopMonitoring() {
    monitor.cancel()
  }

  private func setConnectionType(_ path: NWPath) {
    switch true {
    case path.usesInterfaceType(.wifi):
      connectionType = .wifi
    case path.usesInterfaceType(.cellular):
      connectionType = .cellular
    case path.usesInterfaceType(.wiredEthernet):
      connectionType = .ethernet
    default:
      connectionType = .unknown
    }
  }
}
