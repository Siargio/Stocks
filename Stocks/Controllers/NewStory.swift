//
//  NewStory.swift
//  Stocks
//
//  Created by Sergio on 28.04.23.
//

import Foundation

struct NewStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
