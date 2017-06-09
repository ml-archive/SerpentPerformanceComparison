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
import Marshal
@testable import SerpentComparison

extension PerformanceTestSmallModel : Equatable {
    static func ==(lhs: PerformanceTestSmallModel, rhs: PerformanceTestSmallModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

class SerpentComparisonTests: XCTestCase {
    
    var largeData: Data!
    var smallData: Data!
    
    override func setUp() {
        super.setUp()

        let bundle = Bundle(for: type(of: self))
        if let path = bundle.url(forResource: "PerformanceTest", withExtension: "json"),
            let data = try? Data(contentsOf: path) {
            largeData = data
        }
        if let path = bundle.url(forResource: "PerformanceSmallTest", withExtension: "json"),
            let data = try? Data(contentsOf: path) {
            smallData = data
        }
    }
    
    // Apparently, Xcode runs the test in alphabetical order. We want the correctness test to be first so the performance results can be easily seen afterwards. Hence, the ugly naming style
    func test_correctness() {
        // parse the small model with all the frameworks and test that the resulted struct has the same values and that they're the expected ones
        
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: self.smallData, options: .allowFragments) as! NSDictionary
            
            // serpent
            let serpentParsedModel = PerformanceTestSmallModel.array(jsonDict["data"])
            
            // freddy
            let smallFreddyDict = try Freddy.JSON(data: smallData)
            let freddyParsedModel = try smallFreddyDict.getArray(at: "data").map(PerformanceTestSmallModel.init)
            
            // gloss
            guard let objects = jsonDict["data"] as? [Gloss.JSON] else {
                XCTFail("Gloss parsing failed")
                return
            }
            let glossParsedModel = [PerformanceTestSmallModel].from(jsonArray: objects)
            
            // object mapper
            let objectMapperParsedModel = Mapper<PerformanceTestSmallModel>().mapArray(JSONObject: jsonDict["data"])
            
            // jsoncodable
            let jsonCodableParsedModel = try Array<PerformanceTestSmallModel>(JSONArray: jsonDict["data"] as! [[String: AnyObject]])
            
            // unbox
            let unboxParsedModel : [PerformanceTestSmallModel] = try unbox(dictionaries: jsonDict["data"] as! [[String : AnyObject]])
            
            // decodable
            let decodableParsedModel : [PerformanceTestSmallModel] = try [PerformanceTestSmallModel].decode(jsonDict["data"] as! [[String : AnyObject]])

            // marshal
            let marshalParsedModel : [PerformanceTestSmallModel] = try jsonDict.value(for: "data")
            
            // make sure you add a check here for the newly added mapping frameworks
            let allParsedModelsAreTheSame =
                       serpentParsedModel == freddyParsedModel
                    && freddyParsedModel == glossParsedModel!
                    && glossParsedModel! == objectMapperParsedModel!
                    && objectMapperParsedModel! == jsonCodableParsedModel
                    && jsonCodableParsedModel == unboxParsedModel
                    && unboxParsedModel == decodableParsedModel
                    && marshalParsedModel == unboxParsedModel
            
            // since we checked if they're all equal, we can only check the first one for correctness
            let parsedModelIsDifferentThanDefaultValues = serpentParsedModel[1].id != "" && serpentParsedModel[1].name != ""
            let firstParsedModelIsCorrect = serpentParsedModel[0].id == "56cf0c0c529c7a385b328947" && serpentParsedModel[0].name == "Jana"
            
            XCTAssert(allParsedModelsAreTheSame && parsedModelIsDifferentThanDefaultValues && firstParsedModelIsCorrect)
            
        }
        catch {
            XCTFail(error.localizedDescription)
        }
        
        
    }
    
    func testSerpentBig() {
        self.measure { () -> Void in
            do {
                let jsonDict = try JSONSerialization.jsonObject(with: self.largeData, options: .allowFragments) as! NSDictionary
                let _ = PerformanceTestModel.array(jsonDict["data"])
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testSerpentSmall() {
        self.measure {
            do {
                let smallJsonDict = try JSONSerialization.jsonObject(with: self.smallData, options: .allowFragments) as! NSDictionary
                let _ = PerformanceTestSmallModel.array(smallJsonDict["data"])
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testFreddyBig() {
        self.measure {
            do {
                let freddyDict = try Freddy.JSON(data: self.largeData)
                let _ = try freddyDict.getArray(at: "data").map(PerformanceTestModel.init)
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testFreddySmall() {
        self.measure {
            do {
                let smallFreddyDict = try Freddy.JSON(data: self.smallData)
                let _ = try smallFreddyDict.getArray(at: "data").map(PerformanceTestSmallModel.init)
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testGlossBig() {
        self.measure {
            do {
                let glossDict = try JSONSerialization.jsonObject(with: self.largeData, options: .allowFragments) as! Gloss.JSON
                if let objects = glossDict["data"] as? [Gloss.JSON] {
                    let _ = [PerformanceTestModel].from(jsonArray: objects)
                }
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testGlossSmall() {
        self.measure {
            do {
                let smallGlossDict = try JSONSerialization.jsonObject(with: self.smallData, options: .allowFragments) as! Gloss.JSON
                if let objects = smallGlossDict["data"] as? [Gloss.JSON] {
                    let _ = [PerformanceTestSmallModel].from(jsonArray: objects)
                }
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testObjectMapperBig() {
        self.measure {
            do {
                let objectMapperDict = try JSONSerialization.jsonObject(with: self.largeData, options: .allowFragments) as! NSDictionary
                let _ = Mapper<PerformanceTestModel>().mapArray(JSONObject: (objectMapperDict["data"]))
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testObjectMapperSmall() {
        self.measure {
            do {
                let objectMapperSmallDict = try JSONSerialization.jsonObject(with: self.smallData, options: .allowFragments) as! NSDictionary
                let _ = Mapper<PerformanceTestSmallModel>().mapArray(JSONObject: objectMapperSmallDict["data"])
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testJSONCodableBig() {
        self.measure {
            do {
                let jsonCodableDict = try JSONSerialization.jsonObject(with: self.largeData, options: .allowFragments) as! [String: AnyObject]
                let _ = try Array<PerformanceTestModel>(JSONArray: jsonCodableDict["data"] as! [[String: AnyObject]])
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testJSONCodableSmall() {
        self.measure {
            do {
                let jsonCodableSmallDict = try JSONSerialization.jsonObject(with: self.smallData, options: .allowFragments) as! [String: AnyObject]
                let _ = try Array<PerformanceTestSmallModel>(JSONArray: jsonCodableSmallDict["data"] as! [[String: AnyObject]])
                
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testUnboxBig() {
        self.measure {
            do {
                let unboxDict = try JSONSerialization.jsonObject(with: self.largeData, options: .allowFragments) as! [String: AnyObject]
                let _ : [PerformanceTestModel] = try unbox(dictionaries: unboxDict["data"] as! [[String : AnyObject]])
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testUnboxSmall() {
        self.measure {
            do {
                let unboxSmallDict = try JSONSerialization.jsonObject(with: self.smallData, options: .allowFragments) as! [String: AnyObject]
                let _ : [PerformanceTestSmallModel] = try unbox(dictionaries: unboxSmallDict["data"] as! [[String : AnyObject]])
                
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testDecodableBig() {
        self.measure {
            do {
                let decodableDict = try JSONSerialization.jsonObject(with: self.largeData, options: .allowFragments) as! [String : AnyObject]
                let _ : [PerformanceTestModel] = try [PerformanceTestModel].decode(decodableDict["data"] as! [[String : AnyObject]])
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testDecodableSmall() {
        self.measure {
            do {
                let decodableSmallDict = try JSONSerialization.jsonObject(with: self.smallData, options: .allowFragments) as! [String: AnyObject]
                let _ : [PerformanceTestSmallModel] = try [PerformanceTestSmallModel].decode(decodableSmallDict["data"] as! [[String : AnyObject]])
                
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMarshalBig() {
        self.measure {
            do {
                let marshalDict = try Marshal.JSONParser.JSONObjectWithData(self.largeData)
                let _ : [PerformanceTestModel] = try marshalDict.value(for: "data")
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testMarshalSmall() {
        self.measure {
            do {
                let smallMarshalDict = try Marshal.JSONParser.JSONObjectWithData(self.smallData)
                let _ : [PerformanceTestSmallModel] = try smallMarshalDict.value(for: "data")
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testCodableBig() {
        self.measure {
            do {
                let decoder = JSONDecoder()
                let _: DataPerformanceTestModel = try decoder.decode(DataPerformanceTestModel.self, from: self.largeData)
            }
            catch {
                print(error)
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testCodableSmall() {
        self.measure {
            do {
                let decoder = JSONDecoder()
                let _: DataPerformanceTestSmallModel = try decoder.decode(DataPerformanceTestSmallModel.self, from: self.smallData)
            }
            catch {
                print(error)
                XCTFail(error.localizedDescription)
            }
        }
    }
}
