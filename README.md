#Serpent Performance Tests

So how fast is Serpent? Why should I use Serpent instead of one of the many other Encoding/Decoding frameworks out there? What features does Serpent lack?

*Lets find out!*

**Note:** All of the following can be found in the [Performance Tests](https://github.com/nodes-ios/SerpentPerformanceComparison/blob/master/SerpentComparisonTests/SerpentComparisonTests.swift) in this repo. 

##The Data
We need something big to test. Parsing a small 10-line JSON object doesn't help illustrate performance. So let's see how it does with an object like this: 

~~~
{
	"id": "56cf043e934a463a49375405"
	"index" : 0,
	"guid": "8dfb0059-93fc-4369-83a8-60cbad659d5f",
	"isActive": true,
	"balance": "$3,976.78",
	"picture": "http://placehold.it/32x32",
	"age": 22,
	"eyeColor": "green",
	"name": {
		"last": "Workman",
		"first": "Rhonda"
	},
	"company": "PLASMOSIS",
	"email": "rhonda.workman@plasmosis.co.uk",
	"phone": "+1 (823) 453-2185",
	"address": "311 Scott Avenue, Maplewood, Kansas, 2955",
	"about": "Commodo veniam pariatur ea ut duis incididunt. Eiusmod consequat quis ex consequat cillum exercitation enim voluptate eiusmod aliquip. Sunt dolor ea cillum nisi commodo aliqua velit dolor. Ad incididunt sint est consequat eiusmod laboris anim aute velit dolore ut ea sint Lorem. Tempor consectetur incididunt minim sunt ipsum velit ut et duis occaecat enim. Est exercitation eiusmod mollit incididunt occaecat occaecat do. Laboris ea enim eu dolor duis est occaecat est enim amet proident id.",
	"registered": "Saturday, June 6, 2015 9:22 AM",
	"latitude": "16.640946",
	"longitude": "-122.190771",
	"greeting": "Hello, Rhonda! You have 7 unread messages.",
	"favoriteFruit": "strawberry"
}

~~~

A good mix of types, there are `Int`, `String`, `Enum`, `NSURL`, and nested Objects. But again, this isn't enough for useful metrics. [So lets use 10,000 of these](https://github.com/nodes-ios/SerpentPerformanceComparison/blob/master/SerpentComparisonTests/PerformanceTest.json). A 10.1 MB file should be good enough. 

Let's also test 10,000 of a smaller object as well, to see how that impacts performance:

~~~
{
	"id": "56cf0c0c4d93367b1d9282b3",
	"name": "Catherine"
}
~~~

[This file](https://github.com/nodes-ios/SerpentPerformanceComparison/blob/master/SerpentComparisonTests/PerformanceSmallTest.json) is only 6% of the bigger file's size.


##The Models

So let's create our models now. We want to make the data as useful as possible, so we should use the appropriate data types when possible (not just using `String` for everything). 

~~~swift
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
	var isActive = true 
	var balance = ""
	var picture: NSURL?
	var age = 0
	var eyeColor: EyeColor = .Brown 
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
	var favoriteFruit: Fruit? 
}
struct Name {
	var first = ""
	var last = ""
}
~~~

~~~swift
struct PerformanceTestSmallModel {	
	var id = ""
	var name = ""
}
~~~

Serpent doesn't care if you use implicit or explicit types, so it is only added when needed (for `Enum`, nested types, or optionals, for example). Also, we could of course use optionals for these fields instead of default values (`favoriteFruit` vs. `eyeColor`, for example). 


##Decoding

So now we want to parse the JSON into this model. With Serpent, this is done by conforming to `Decodable` and implementing `init(dictionary:NSDictionary?)` (all done automatically in a split-second if you use our [![ModelBoiler](http://i.imgur.com/V5UzMVk.png)](https://github.com/nodes-ios/ModelBoiler) [Model Boiler](https://github.com/nodes-ios/ModelBoiler): 

~~~swift
extension PerformanceTestModel: Serializable {
	init(dictionary: NSDictionary?) {
		id            <== (self, dictionary, "id")
		index         <== (self, dictionary, "index")
		guid          <== (self, dictionary, "guid")
		isActive      <== (self, dictionary, "isActive")
		balance       <== (self, dictionary, "balance")
		picture       <== (self, dictionary, "picture")
		age           <== (self, dictionary, "age")
		eyeColor      <== (self, dictionary, "eyeColor")
		name          <== (self, dictionary, "name")
		company       <== (self, dictionary, "company")
		email         <== (self, dictionary, "email")
		phone         <== (self, dictionary, "phone")
		address       <== (self, dictionary, "address")
		about         <== (self, dictionary, "about")
		registered    <== (self, dictionary, "registered")
		latitude      <== (self, dictionary, "latitude")
		longitude     <== (self, dictionary, "longitude")
		greeting      <== (self, dictionary, "greeting")
		favoriteFruit <== (self, dictionary, "favoriteFruit")
	}
}
~~~

Now PerformanceTestModel is ready to decode some JSON. Since loading the raw JSON data isn't something Serpent (or any other similar framework) is concerned with, we don't need to test the performance of that, so we'll just load the data like this:

~~~swift
 override func setUp() {
 	super.setUp()		
	if let path = NSBundle(forClass: self.dynamicType).pathForResource("PerformanceTest", ofType: "json"), data = NSData(contentsOfFile: path) {
		largeData = data
	}
	if let path = NSBundle(forClass: self.dynamicType).pathForResource("PerformanceSmallTest", ofType: "json"), data = NSData(contentsOfFile: path) {
		smallData = data
	}		 
}
~~~

Normally, we would also parse this JSON data into a dictionary using `NSJSONSerialization`, but some frameworks have their own JSON parsing logic, so we'll measure the performance of the parsing as well as decoding. 

So let's test it!

~~~swift
func testBigPerformance() {
		self.measureBlock { () -> Void in
			do {
				self.jsonDict = try NSJSONSerialization.JSONObjectWithData(self.largeData, options: .AllowFragments) as? NSDictionary
				let _ = PerformanceTestModel.array(self.jsonDict["data"])
			}
			catch {
				print(error)
			}
		}
    }

	func testSmallPerformance() {
		self.measureBlock {
			do {
				self.smallJsonDict = try NSJSONSerialization.JSONObjectWithData(self.smallData, options: .AllowFragments) as? NSDictionary
				let _ = PerformanceTestSmallModel.array(self.smallJsonDict["data"])
			}
			catch {
				print(error)
			}
		}
	}
~~~

**Note:** All of these tests are run using the iPhone SE simulator after a clean build, on a MacBook Pro Retina, 15-inch, Mid 2014, with a 2,8 GHz Intel Core i7 Processor and 16 GB RAM.

Test | Result
---|---
Serpent Large Model | 0.424 sec
Serpent Small Model | 0.059 sec


Not too bad for 10,000 objects. But how does it compare to other frameworks? We looked at 4 other popular frameworks to compare our results. 

[Freddy](https://github.com/bignerdranch/Freddy)

[Gloss](https://github.com/hkellaway/Gloss)

[ObjectMapper](https://github.com/Hearst-DD/ObjectMapper)

[JSONCodable](https://github.com/matthewcheok/JSONCodable)

Before we can compare results, we have a few issues to resolve. Freddy only supports primitive types and collections, so no `Enum`, `NSURL`, or odd cases (such as the latitude and longitude fields, which are `String` in the JSON but `Double` in our model). JSONCodable and ObjectMapper can't handle the `NSURL`. So to be fair, we'll remove those properties from the test. 

**Note:** I'm not going to list the implementations for all of these frameworks, as they would make this document way too long. If you're curious, you can have a look at [the test file](https://github.com/nodes-ios/SerpentPerformanceComparison/blob/master/SerpentComparisonTests/SerpentComparisonTests.swift). 

Test | Large Model | Small Model
---|---|---
Serpent | 0.424 sec | 0.059 sec
Freddy       | 0.419 sec | 0.055 sec
Gloss        | 1.775 sec | 0.248 sec
ObjectMapper | 1.190 sec | 0.196 sec
JSONCodable  | 2.800 sec | 0.330 sec

####So what does this mean?

When it comes to Decoding, ** Serpent** and **Freddy** are the fastest. When this test is run, sometimes Freddy is faster, sometimes Serpent is faster, but the difference is pretty negligible. 

##Encoding

> **Coming soon**

##Feature Comparison

So you've seen the performance tests, but what about features? 

 | Serpent | Freddy | Gloss | ObjectMapper | JSONCodable
---|---|---|---|---|---
Parses primitive types|✔️|✔️|✔️|✔️|✔️
Parses nested objects|✔️|✔️|✔️|✔️|✔️
Parses Enum types|✔️|❌|✔️|✔️|✔️
Parses other types (e.g. NSURL, UIColor)|✔️|❌|✔️|❌|❌
Easy protocol conformance syntax with custom operator|✔️|❌|✔️|✔️|❌
Flexible mapping function without complicated generics syntax or casting|✔️|✔️|❌|❌|❌
Decodes without needing to handle errors|✔️|❌|✔️|✔️|❌
Auto-generated code from Model Boiler|✔️|❌|❌|❌|❌
**Best Performance**|✔️|✔️|❌|❌|❌


##TL:DR
Serpent is the fastest and most feature rich JSON encoder and decoder available. But don't take our word for it, try it out and see for yourself! And don't forget, we have the [![ModelBoiler](http://i.imgur.com/V5UzMVk.png)](https://github.com/nodes-ios/ModelBoiler) [Model Boiler](https://github.com/nodes-ios/ModelBoiler), which saves loads of time and makes your life much easier. 