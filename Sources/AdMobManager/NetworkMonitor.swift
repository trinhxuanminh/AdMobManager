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
    
    fileprivate let queue = DispatchQueue.global()
    fileprivate let monitor: NWPathMonitor
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown
    
    init() {
        self.monitor = NWPathMonitor()
        self.startMonitoring()
    }
    
    private func startMonitoring() {
        self.monitor.start(queue: self.queue)
        self.monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            
            self?.setConnectionType(path)
        }
    }
    
    private func stopMonitoring() {
        self.monitor.cancel()
    }
    
    private func setConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            self.connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            self.connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            self.connectionType = .ethernet
        } else {
            self.connectionType = .unknown
        }
    }
}
