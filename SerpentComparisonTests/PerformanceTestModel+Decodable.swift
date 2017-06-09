//
//  PerformanceTestModel+Decodable.swift
//  SerpentComparison
//
//  Created by Marius Constantinescu on 22/02/2017.
//  Copyright © 2017 Nodes. All rights reserved.
//

import Foundation
import Decodable
import protocol Decodable.Decodable

// Decodable

extension PerformanceTestModel: Decodable {
    public static func decode(_ json: Any) throws -> PerformanceTestModel {
        return try PerformanceTestModel(
            id: json => "id",
            index: json => "index",
            guid: json => "guid",
            isActive: json => "isActive",
            balance: json => "balance",
                        picture: nil,//json => "picture",
            age: json => "age",
                        eyeColor: .Brown,//json => "eyeColor",
            name: json => "name",
            company: json => "company",
            email: json => "email",
            phone: json => "phone",
            address: json => "address",
            about: json => "about",
            registered: json => "registered",
                        latitude: 0.0,//json => "latitude",
                        longitude: 0.0,//json => "longitude",
            greeting: json => "greeting",
                        favoriteFruit: nil//json => "favoriteFruit"
        )
    }
}

extension Name: Decodable {
    public static func decode(_ json: Any) throws -> Name {
        return try Name(
            first: json => "first",
            last: json => "last"
        )
    }
}
