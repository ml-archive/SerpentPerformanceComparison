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



struct PerformanceTestModel {
	
	enum EyeColor: String {
		case Blue = "blue"
		case Green = "green"
		case Brown = "brown"
	}
	
	enum Fruit: String {
		case Apple = "apple"
		case Banana = "banana"
		case Strawberry = "strawberry"
	}
	
	var id = ""
	var index = 0
	var guid = ""
	var isActive = true //<- isActive
	var balance = ""
	var picture: NSURL?
	var age = 0
	var eyeColor: EyeColor = .Brown //<- eyeColor
	var name = Name()
	var company = ""
	var email = ""
	var phone = ""
	var address = ""
	var about = ""
	var registered = ""
	var latitude = 0.0
	var longitude = 0.0
	var greeting = ""
	var favoriteFruit: Fruit? //<- favoriteFruit
}

extension PerformanceTestModel: Serializable {
	init(dictionary: NSDictionary?) {
		id            <== (self, dictionary, "id")
		index         <== (self, dictionary, "index")
		guid          <== (self, dictionary, "guid")
		isActive      <== (self, dictionary, "isActive")
		balance       <== (self, dictionary, "balance")
//		picture       <== (self, dictionary, "picture")
		age           <== (self, dictionary, "age")
//		eyeColor      <== (self, dictionary, "eyeColor")
		name          <== (self, dictionary, "name")
		company       <== (self, dictionary, "company")
		email         <== (self, dictionary, "email")
		phone         <== (self, dictionary, "phone")
		address       <== (self, dictionary, "address")
		about         <== (self, dictionary, "about")
		registered    <== (self, dictionary, "registered")
//		latitude      <== (self, dictionary, "latitude")
//		longitude     <== (self, dictionary, "longitude")
		greeting      <== (self, dictionary, "greeting")
//		favoriteFruit <== (self, dictionary, "favoriteFruit")
	}
	
	func encodableRepresentation() -> NSCoding {
		let dict = NSMutableDictionary()
		(dict, "id")            <== id
		(dict, "index")         <== index
		(dict, "guid")          <== guid
		(dict, "isActive")      <== isActive
		(dict, "balance")       <== balance
		(dict, "picture")       <== picture
		(dict, "age")           <== age
		(dict, "eyeColor")      <== eyeColor
		(dict, "name")          <== name
		(dict, "company")       <== company
		(dict, "email")         <== email
		(dict, "phone")         <== phone
		(dict, "address")       <== address
		(dict, "about")         <== about
		(dict, "registered")    <== registered
		(dict, "latitude")      <== latitude
		(dict, "longitude")     <== longitude
		(dict, "greeting")      <== greeting
		(dict, "favoriteFruit") <== favoriteFruit
		return dict
	}
}

struct Name {
	var first = ""
	var last = ""
}

extension Name: Serializable {
	init(dictionary: NSDictionary?) {
		first <== (self, dictionary, "first")
		last  <== (self, dictionary, "last")
	}
	
	func encodableRepresentation() -> NSCoding {
		let dict = NSMutableDictionary()
		(dict, "first") <== first
		(dict, "last")  <== last
		return dict
	}
}


/////////////////////////////////////
/*
	Other libraries
*/


// Freddy
extension PerformanceTestModel: Freddy.JSONDecodable {
	init(json value: Freddy.JSON) throws {
		id = try value.getString(at: "id")
		index = try value.getInt(at: "index")
		guid = try value.getString(at: "guid")
		isActive = try value.getBool(at: "isActive")
		balance = try value.getString(at: "balance")
		//picture = try value.
		age = try value.getInt(at: "age")
		//eyeColor = try value.
		name = try value.decode(at: "name")
		company = try value.getString(at: "company")
		email = try value.getString(at: "email")
		phone = try value.getString(at: "phone")
		address = try value.getString(at: "address")
		about = try value.getString(at: "about")
		registered = try value.getString(at: "registered")
		//latitude = try value.double("latitude")
		//longitude = try value.double("longitude")
		greeting = try value.getString(at: "greeting")
		//favoriteFruit = try value.
	}
}

extension Name: Freddy.JSONDecodable {
	init(json value: Freddy.JSON) throws {
		first = try value.getString(at: "first")
		last = try value.getString(at: "last")
	}
}

// Gloss
extension PerformanceTestModel: Gloss.Decodable {
	init?(json: Gloss.JSON) {
		id          =  "id" <~~ json ?? id
		index       =  "index" <~~ json ?? index
		guid        =  "guid" <~~ json ?? guid
		isActive    =  "isActive" <~~ json ?? isActive
		balance     =  "balance" <~~ json ?? balance
//		picture     =  "picture" <~~ json
		age         =  "age" <~~ json ?? age
//		eyeColor    =  "eyeColor" <~~ json ?? eyeColor
		name        =  "name" <~~ json ?? name
		company     =  "company" <~~ json ?? company
		email       =  "email" <~~ json ?? email
		phone       =  "phone" <~~ json ?? phone
		address     =  "address" <~~ json ?? address
		about       =  "about" <~~ json ?? about
		registered  =  "registered" <~~ json ?? registered
//		latitude    =  "latitude" <~~ json ?? latitude
//		longitude   =  "longitude" <~~ json ?? longitude
		greeting    =  "greeting" <~~ json ?? greeting
		favoriteFruit = "favoriteFruit" <~~ json
	}
}

extension Name: Gloss.Decodable {
	init?(json: Gloss.JSON) {
		first = "first" <~~ json ?? first
		last = "last" <~~ json ?? last
	}
}

// ObjectMapper

extension PerformanceTestModel: Mappable {
    init?(map: Map) {
        
    }
	mutating func mapping(map: Map) {
		id				<- map["id"]
		index           <- map["index"]
		guid			<- map["guid"]
		isActive        <- map["isActive"]
		balance         <- map["balance"]
//		picture			<- map["picture"]
		age				<- map["age"]
//		eyeColor		<- map["eyeColor"]
		name			<- map["name"]
		company         <- map["company"]
		email           <- map["email"]
		phone           <- map["phone"]
		address         <- map["address"]
		about           <- map["about"]
		registered      <- map["registered"]
//		latitude		<- map["latitude"]
//		longitude		<- map["longitude"]
		greeting        <- map["greeting"]
//		favoriteFruit   <- map["favoriteFruit"]
	}
}

extension Name: Mappable {
    init?(map: Map) {
        
    }
	mutating func mapping(map: Map) {
		first <- map["first"]
		last <- map["last"]
	}
	
}

// JSONCodable

extension PerformanceTestModel: JSONCodable {
	init(object: JSONObject) throws {
		let decoder = JSONDecoder(object: object)
		
		id = try decoder.decode("id")
		index = try decoder.decode("index")
		guid = try decoder.decode("guid")
		isActive = try decoder.decode("isActive")
		balance = try decoder.decode("balance")
//		picture = try decoder.decode("picture")
		age = try decoder.decode("age")
//		eyeColor = try decoder.decode("eyeColor")
		name = try decoder.decode("name")
		company = try decoder.decode("company")
		email = try decoder.decode("email")
		phone = try decoder.decode("phone")
		address = try decoder.decode("address")
		about = try decoder.decode("about")
		registered = try decoder.decode("registered")
//		latitude = try decoder.decode("latitude")
//		longitude = try decoder.decode("longitude")
		greeting = try decoder.decode("greeting")
//		favoriteFruit = try decoder.decode("favoriteFruit")
	}
}

extension Name: JSONCodable {
	init(object: JSONObject) throws {
		let decoder = JSONDecoder(object: object)
		
		first = try decoder.decode("first")
		last = try decoder.decode("last")
		
	}
}


// Unbox

extension PerformanceTestModel: Unboxable {
    init(unboxer: Unboxer) throws {
        
        id = try unboxer.unbox(key: "id")
        index = try unboxer.unbox(key: "index")
        guid = try unboxer.unbox(key: "guid")
        isActive = try unboxer.unbox(key: "isActive")
        balance = try unboxer.unbox(key: "balance")
        //		picture = try unboxer.unbox(key: "picture")
        age = try unboxer.unbox(key: "age")
        //		eyeColor = try unboxer.unbox(key: "eyeColor")
        name = try unboxer.unbox(key: "name")
        company = try unboxer.unbox(key: "company")
        email = try unboxer.unbox(key: "email")
        phone = try unboxer.unbox(key: "phone")
        address = try unboxer.unbox(key: "address")
        about = try unboxer.unbox(key: "about")
        registered = try unboxer.unbox(key: "registered")
        //		latitude = try unboxer.unbox(key: "latitude")
        //		longitude = try unboxer.unbox(key: "longitude")
        greeting = try unboxer.unbox(key: "greeting")
        //		favoriteFruit = try unboxer.unbox(key: "favoriteFruit")
    }
}

extension Name: Unboxable {
    init(unboxer: Unboxer) throws {
        
        first = try unboxer.unbox(key: "first")
        last = try unboxer.unbox(key: "last")
        
    }
}


