//
//  MakeHttpJsonRequest.swift
//  XSwiftUI
//
//  Created by Shahanul Haque on 4/19/25.
//



import EasyXConnect
import Foundation

final class MakeHttpJsonRequest: Intercepter {
    func onRequest(req: URLRequest) async throws -> (URLRequest, Data?) {

        var mutableReq = req  // Create a mutable copy of the original URLRequest

        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]

        headers.forEach { key, value in
            // Only set the header if it's not already set
            if mutableReq.value(forHTTPHeaderField: key) == nil {
                mutableReq.setValue(value, forHTTPHeaderField: key)
            }
        }

        return (mutableReq, nil)
    }
    
    func onResponse(req: URLRequest, res: URLResponse?, data: Data,modifiedData: Data?, customResponse: URLResponse?) async throws -> (Data, URLResponse?) {
        return (data, customResponse)
    }
}
