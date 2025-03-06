//
//  URLExtension.swift
//  ZeusApp
//
//  Created by Quenting on 16/02/2025.
//

import Foundation

extension URL {
    // https://stackoverflow.com/questions/41421686/get-the-value-of-url-parameters
    func getParameterValue(_ queryParameterName: String) -> String? {
        // Meant to be used with an url that uses # instead of ? for the url parameters, so actualy not used in my case. Still keeping it here just in case for now.
        // It us used below tho
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}

func getURLParameterValue(url: String, _ queryParameterName: String) -> String? {
    guard let url = URLComponents(string: url) else { return nil }
    return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
}
