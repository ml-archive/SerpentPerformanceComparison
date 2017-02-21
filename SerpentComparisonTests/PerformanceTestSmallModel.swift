//
//  PerformanceTestModel.swift
//  Serializable
//
//  Created by Chris Combs on 25/02/16.
//  Copyright © 2016 Nodes. All rights reserved.
//


import Serpent
import Freddy
import Gloss
import ObjectMapper
import JSONCodable
import Unbox

struct PerformanceTestSmallModel {	
	var id = ""
	var name = ""
}


// Serpent
extension PerformanceTestSmallModel: Serializable {
	init(dictionary: NSDictionary?) {
		id   <== (self, dictionary, "id")
		name <== (self, dictionary, "name")
	}
	
	func encodableRepresentation() -> NSCoding {
		let dict = NSMutableDictionary()
		(dict, "id")   <== id
		(dict, "name") <== name
		return dict
	}
}

/////////////////////////////////////
/*
Other libraries
*/

// Freddy
extension PerformanceTestSmallModel: Freddy.JSONDecodable {
	init(json value: Freddy.JSON) throws {
        id = try value.getString(at: "id")
        name = try value.getString(at: "name")
	}
}

// Gloss

extension PerformanceTestSmallModel: Gloss.Decodable {
	init?(json: Gloss.JSON) {
		id = "id" <~~ json ?? id
		name = "name" <~~ json ?? name
	}
}

// ObjectMapper

extension PerformanceTestSmallModel: Mappable {
    init?(map: Map) {
        
    }
	mutating func mapping(map: Map) {
		id <- map["id"]
		name <- map["name"]
	}
}

// JSONCodable

extension PerformanceTestSmallModel: JSONCodable {
	init(object: JSONObject) throws {
		let decoder = JSONDecoder(object: object)
		id = try decoder.decode("id")
		name = try decoder.decode("name")
	}
}



// Unbox

extension PerformanceTestSmallModel: Unboxable {
    init(unboxer: Unboxer) throws {
        
        id = try unboxer.unbox(key: "id")
        name = try unboxer.unbox(key: "name")
    }
}
