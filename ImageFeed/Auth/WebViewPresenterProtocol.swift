//
//  AuthProtocols.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 24.05.2026.
//

import Foundation

public protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}
