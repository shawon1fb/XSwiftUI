//
//  HTTPClient.swift
//  XSwiftUI
//
//  Created by Shahanul Haque on 4/19/25.
//

import EasyX
import EasyXConnect
import Foundation

public enum URLError: Error {
  case URLNotFoundOrRegistered
}

public final class HTTPClient {

  static public func getClient(name: String? = nil, defaultUrl: URL? = nil) throws -> ExHttpConnect
  {

    if let client = try? DIContainer.shared.resolve(ExHttpConnect.self, name: name) {
      return client
    } else {

      let registerUrl = try? DIContainer.shared.resolve(URL.self, name: "base_url")

      let url: URL? = registerUrl ?? defaultUrl

      guard let url = url else { throw URLError.URLNotFoundOrRegistered }

      let configuration = URLSessionConfiguration.default
      configuration.httpCookieAcceptPolicy = .never
      configuration.httpShouldSetCookies = false
      let session = URLSession(
        configuration: configuration,
        delegate: nil,
        delegateQueue: OperationQueue()
      )
      var intercepters: [Intercepter] = []
      let registeredIntercepters: [Intercepter]? = try? DIContainer.shared.resolve(
        [Intercepter].self)
      if let registeredIntercepters = registeredIntercepters {
        intercepters.append(contentsOf: registeredIntercepters)
      }

      let defaultInterseptor: [Intercepter] = [
        ApiKeyInterceptor(),
        MakeHttpJsonRequest(),
      ]

      intercepters.append(contentsOf: defaultInterseptor)

      if let level = try? DIContainer.shared.resolve(EnumResponsePrinter.self) {
        intercepters.append(ResponsePrinter(level: level))
      }

      let client = ExHttpConnect(baseURL: url, session: session, intercepters: intercepters)

      DIContainer.shared.register(ExHttpConnect.self, name: name) { r in
        return client
      }
      return client
    }
  }

  static public func registerBaseUrl(url: String) {
    if let url = URL(string: url) {
      DIContainer.shared.register(URL.self, name: "base_url") { _ in
        return url
      }
    }
  }

  static public func enableResponsePrint(label: EnumResponsePrinter) {
    DIContainer.shared.register(EnumResponsePrinter.self) { _ in
      return label
    }
  }

  static public func registerInterceptors(_ interceptors: [Intercepter]) {
    DIContainer.shared.register([Intercepter].self) { _ in
      return interceptors
    }
  }

}
