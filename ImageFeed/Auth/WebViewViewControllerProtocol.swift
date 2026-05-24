//
//  WebViewViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 24.05.2026.
//

import UIKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}
