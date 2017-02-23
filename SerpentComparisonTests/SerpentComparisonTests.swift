//
//  SerpentComparisonTests.swift
//  SerpentComparisonTests
//
//  Created by Marius Constantinescu on 15/02/2017.
//  Copyright © 2017 Nodes. All rights reserved.
//

import XCTest
import Freddy
import Gloss
import ObjectMapper
import Serpent
import Unbox
import Decodable
@testable import SerpentComparison

extension PerformanceTestSmallModel : Equatable {
    static func ==(lhs: PerformanceTestSmallModel, rhs: PerformanceTestSmallModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

class SerpentComparisonTests: XCTestCase {
    
    var largeData: NSData!
    var smallData: NSData!
    
    var jsonDict: NSDictionary!
    var smallJsonDict: NSDictionary!
    
    var freddyDict: Freddy.JSON!
    var smallFreddyDict: Freddy.JSON!
    
    var glossDict: Gloss.JSON!
    var smallGlossDict: Gloss.JSON!
    
    var objectMapperDict: NSDictionary!
    var objectMapperSmallDict: NSDictionary!
    
    var jsonCodableDict: [String: AnyObject]!
    var jsonCodableSmallDict: [String: AnyObject]!
    
    var unboxDict: [String : AnyObject]!
    var unboxSmallDict: [String : AnyObject]!
    
    var decodableDict: [String : AnyObject]!
    var decodableSmallDict: [String : AnyObject]!
    
    override func setUp() {
        super.setUp()
        if let path = Bundle(for: type(of: self)).path(forResource: "PerformanceTest", ofType: "json"), let data = NSData(contentsOfFile: path) {
            largeData = data
        }
        if let path = Bundle(for: type(of: self)).path(forResource: "PerformanceSmallTest", ofType: "json"), let data = NSData(contentsOfFile: path) {
            smallData = data
        }
    }
    
    // Apparently, Xcode runs the test in alphabetical order. We want the correctness test to be first so the performance results can be easily seen afterwards. Hence, the ugly naming style
    func test_correctness() {
        // parse the small model with all the frameworks and test that the resulted struct has the same values and that they're the expected ones
        
        do {
            self.jsonDict = try JSONSerialization.jsonObject(with: self.smallData as Data, options: .allowFragments) as? NSDictionary
            
            // serpent
            let serpentParsedModel = PerformanceTestSmallModel.array(self.jsonDict["data"])
            
            // freddy
            self.smallFreddyDict = try Freddy.JSON(data: self.smallData as Data)
            let freddyParsedModel = try self.smallFreddyDict.getArray(at: "data").map(PerformanceTestSmallModel.init)
            
            // gloss
            guard let objects = self.jsonDict["data"] as? [Gloss.JSON] else {
                XCTFail("Gloss parsing failed")
                return
            }
            let glossParsedModel = [PerformanceTestSmallModel].from(jsonArray: objects)
            
            // object mapper
            let objectMapperParsedModel = Mapper<PerformanceTestSmallModel>().mapArray(JSONObject: self.jsonDict["data"])
            
            // jsoncodable
            let jsonCodableParsedModel = try Array<PerformanceTestSmallModel>(JSONArray: self.jsonDict["data"] as! [[String: AnyObject]])
            
            // unbox
            let unboxParsedModel : [PerformanceTestSmallModel] = try unbox(dictionaries: self.jsonDict["data"] as! [[String : AnyObject]])
            
            // decodable
            let decodableParsedModel : [PerformanceTestSmallModel] = try [PerformanceTestSmallModel].decode(self.jsonDict["data"] as! [[String : AnyObject]])
            
            
            // make sure you add a check here for the newly added mapping frameworks
            let allParsedModelsAreTheSame =
                       serpentParsedModel == freddyParsedModel
                    && freddyParsedModel == glossParsedModel!
                    && glossParsedModel! == objectMapperParsedModel!
                    && objectMapperParsedModel! == jsonCodableParsedModel
                    && jsonCodableParsedModel == unboxParsedModel
                    && unboxParsedModel == decodableParsedModel
            
            let parsedModelIsDifferentThanDefaultValues = serpentParsedModel[1].id != "" && serpentParsedModel[1].name != ""
            let firstParsedModelIsCorrect = serpentParsedModel[0].id == "56cf0c0c529c7a385b328947" && serpentParsedModel[0].name == "Jana"
            
            XCTAssert(allParsedModelsAreTheSame && parsedModelIsDifferentThanDefaultValues && firstParsedModelIsCorrect)
        }
        catch {
            print(error)
        }
        
        
    }
    
    func testSerpentBig() {
        self.measure { () -> Void in
            do {
                self.jsonDict = try JSONSerialization.jsonObject(with: self.largeData as Data, options: .allowFragments) as? NSDictionary
                let _ = PerformanceTestModel.array(self.jsonDict["data"])
            }
            catch {
                print(error)
            }
        }
    }
    
    func testSerpentSmall() {
        self.measure {
            do {
                self.smallJsonDict = try JSONSerialization.jsonObject(with: self.smallData as Data, options: .allowFragments) as? NSDictionary
                let _ = PerformanceTestSmallModel.array(self.smallJsonDict["data"])
            }
            catch {
                print(error)
            }
        }
    }
    
    func testFreddyBig() {
        self.measure {
            do {
                self.freddyDict = try Freddy.JSON(data: self.largeData as Data)
                let _ = try self.freddyDict.getArray(at: "data").map(PerformanceTestModel.init)
            }
            catch {
                print(error)
            }
        }
    }
    
    func testFreddySmall() {
        self.measure {
            do {
                self.smallFreddyDict = try Freddy.JSON(data: self.smallData as Data)
                let _ = try self.smallFreddyDict.getArray(at: "data").map(PerformanceTestSmallModel.init)
            }
            catch {
                print(error)
            }
        }
    }
    
    func testGlossBig() {
        self.measure {
            do {
                self.glossDict = try JSONSerialization.jsonObject(with: self.largeData as Data, options: .allowFragments) as? Gloss.JSON
                if let objects = self.glossDict["data"] as? [Gloss.JSON] {
                    let _ = [PerformanceTestModel].from(jsonArray: objects)
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    func testGlossSmall() {
        self.measure {
            do {
                self.smallGlossDict = try JSONSerialization.jsonObject(with: self.smallData as Data, options: .allowFragments) as? Gloss.JSON
                if let objects = self.smallGlossDict["data"] as? [Gloss.JSON] {
                    let _ = [PerformanceTestSmallModel].from(jsonArray: objects)
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    func testObjectMapperBig() {
        self.measure {
            do {
                self.objectMapperDict = try JSONSerialization.jsonObject(with: self.largeData as Data, options: .allowFragments) as? NSDictionary
                let _ = Mapper<PerformanceTestModel>().mapArray(JSONObject: (self.objectMapperDict["data"]))
            }
            catch {
                print(error)
            }
        }
    }
    
    func testObjectMapperSmall() {
        self.measure {
            do {
                self.objectMapperSmallDict = try JSONSerialization.jsonObject(with: self.smallData as Data, options: .allowFragments) as? NSDictionary
                let _ = Mapper<PerformanceTestSmallModel>().mapArray(JSONObject: self.objectMapperSmallDict["data"])
            }
            catch {
                print(error)
            }
        }
    }
    
    func testJSONCodableBig() {
        self.measure {
            do {
                self.jsonCodableDict = try JSONSerialization.jsonObject(with: self.largeData as Data, options: .allowFragments) as? [String: AnyObject]
                let _ = try Array<PerformanceTestModel>(JSONArray: self.jsonCodableDict["data"] as! [[String: AnyObject]])
            }
            catch {
                print(error)
            }
        }
    }
    
    func testJSONCodableSmall() {
        self.measure {
            do {
                self.jsonCodableSmallDict = try JSONSerialization.jsonObject(with: self.smallData as Data, options: .allowFragments) as? [String: AnyObject]
                let _ = try Array<PerformanceTestSmallModel>(JSONArray: self.jsonCodableSmallDict["data"] as! [[String: AnyObject]])
                
            }
            catch {
                print(error)
            }
        }
    }
    
    func testUnboxBig() {
        self.measure {
            do {
                self.unboxDict = try JSONSerialization.jsonObject(with: self.largeData as Data, options: .allowFragments) as? [String: Any] as [String : AnyObject]!
                let _ : [PerformanceTestModel] = try unbox(dictionaries: self.unboxDict["data"] as! [[String : AnyObject]])
            }
            catch {
                print(error)
            }
        }
    }
    
    func testUnboxSmall() {
        self.measure {
            do {
                self.unboxSmallDict = try JSONSerialization.jsonObject(with: self.smallData as Data, options: .allowFragments) as? [String: AnyObject]
                let _ : [PerformanceTestSmallModel] = try unbox(dictionaries: self.unboxSmallDict["data"] as! [[String : AnyObject]])
                
            }
            catch {
                print(error)
            }
        }
    }
    
    func testDecodableBig() {
        self.measure {
            do {
                self.decodableDict = try JSONSerialization.jsonObject(with: self.largeData as Data, options: .allowFragments) as? [String: Any] as [String : AnyObject]!
                let _ : [PerformanceTestModel] = try [PerformanceTestModel].decode(self.decodableDict["data"] as! [[String : AnyObject]])
            }
            catch {
                print(error)
            }
        }
    }
    
    func testDecodableSmall() {
        self.measure {
            do {
                self.decodableSmallDict = try JSONSerialization.jsonObject(with: self.smallData as Data, options: .allowFragments) as? [String: AnyObject]
                let _ : [PerformanceTestSmallModel] = try [PerformanceTestSmallModel].decode(self.decodableSmallDict["data"] as! [[String : AnyObject]])
                
            }
            catch {
                print(error)
            }
        }
    }
}
