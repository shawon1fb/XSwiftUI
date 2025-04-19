//
//  ResponsePrinter.swift
//  XSwiftUI
//
//  Created by Shahanul Haque on 4/19/25.
//


import EasyXConnect
import Foundation
import os.log

public enum EnumResponsePrinter: Sendable {
  case none
  case all
  case ok
  case notOk
}

final class ResponsePrinter: Intercepter {

  let level: EnumResponsePrinter
  let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.example.app", category: "ResponsePrinter")

  init(level: EnumResponsePrinter) {
    self.level = level
  }

  func log(_ message: String, logLevel: EnumResponsePrinter) {
    switch self.level {
    case .all:
      logger.log("\(message)")
    case .ok:
      if logLevel == .ok || logLevel == .all {
        logger.log("\(message)")
      }
    case .notOk:
      if logLevel == .notOk || logLevel == .all {
        logger.log("\(message)")
      }
    case .none:
      break  // No logging
    }
  }

  func onRequest(req: URLRequest) async throws -> (URLRequest, Data?) {
    return (req, nil)
  }

  func onResponse(req: URLRequest, res: URLResponse?, data: Data,modifiedData: Data?, customResponse: URLResponse?) async throws -> (Data, URLResponse?) {
    let response = res as? HTTPURLResponse
    let statusCode = response?.statusCode ?? 400

    log("URL    : \(response?.url?.absoluteString ?? "" )", logLevel: .all)
    log("METHOD : \(req.httpMethod?.description ?? "" )", logLevel: .all)

    // Logic based on level
    switch level {
    case .all:
      logResponse(req: req, response: response, data: data, statusCode: statusCode)

    case .ok:
      if statusCode < 400 {
        logResponse(req: req, response: response, data: data, statusCode: statusCode)
      }

    case .notOk:
      if statusCode >= 400 {
        logResponse(req: req, response: response, data: data, statusCode: statusCode)
      }

    case .none:
      break  // No logging
    }

    return (data, customResponse)
  }

  private func logResponse(req: URLRequest, response: HTTPURLResponse?, data: Data, statusCode: Int)
  {
    log("----------REQUEST HEADERS---------------", logLevel: .all)
      for (key, value) in req.allHTTPHeaderFields ?? [:] {
        log("\(key): \(value)", logLevel: .all)
      }

    log("----------END---------------", logLevel: .all)
    let jsonData: Data = data

    do {
      if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        as? [String: Any]
      {
        let prettyJsonData = try JSONSerialization.data(
          withJSONObject: jsonObject, options: .prettyPrinted)

        if let prettyJsonString = String(data: prettyJsonData, encoding: .utf8) {
          log("----------JSON START---------------", logLevel: .all)
          log(prettyJsonString, logLevel: .all)
          log("----------END---------------", logLevel: .all)
        }
      }
    } catch {
      log("Error decoding JSON: \(error)", logLevel: .all)
      log("raw response => ", logLevel: .all)
      if let jsonString = String(data: data, encoding: .utf8) {
        log("----------START RAW STRING---------------", logLevel: .all)
        log("\(jsonString)", logLevel: .all)
        log("----------END---------------", logLevel: .all)
      }
    }
  }
}
