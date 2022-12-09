//
//  NetworkMonitor.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 04/04/2022.
//

import Foundation
import Network
import Combine

@available(iOS 13.0, *)
final public class NetworkMonitor {
  public static let shared = NetworkMonitor()

  public enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
  }
  
  @Published public private(set) var isConnected: Bool = true
  @Published public private(set) var connectionType: ConnectionType = .unknown
  private let queue = DispatchQueue.global(qos: .background)
  private let monitor: NWPathMonitor

  init() {
    monitor = NWPathMonitor()
    startMonitoring()
  }

  private func startMonitoring() {
    monitor.start(queue: queue)
    monitor.pathUpdateHandler = { [weak self] path in
      guard let self = self else {
        return
      }
      self.isConnected = path.status == .satisfied
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
