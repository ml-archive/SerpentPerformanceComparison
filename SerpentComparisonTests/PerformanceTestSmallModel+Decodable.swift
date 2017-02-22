//
//  PerformanceTestSmallModel+Decodable.swift
//  SerpentComparison
//
//  Created by Marius Constantinescu on 22/02/2017.
//  Copyright © 2017 Nodes. All rights reserved.
//

import Foundation
import Decodable


// Decodable

extension PerformanceTestSmallModel: Decodable {
    public static func decode(_ json: Any) throws -> PerformanceTestSmallModel {
        return try PerformanceTestSmallModel(
            id: json => "id",
            name: json => "name"
        )
    }
}
