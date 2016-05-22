//
//  Xkcd.swift
//  comic
//
//  Created by Noor Thabit on 9/22/15.
//  Copyright © 2015 Noor Thabit. All rights reserved.
//

import Foundation
class Xkcd {
    
    var day: Int!
    var month: Int!
    var year: Int!
    var num: Int!
    var latestNum: Int!
    var title: String!
    var alt: String!
    var imageURL: String!
    var transcript: String!

    var dataDic: Dictionary<String, AnyObject>!
    
    func getImgUrl() -> String{
        return imageURL
    }
    
    func unwrapStr(dic: Dictionary<String, AnyObject>, key: String) -> String{
        guard let info = dic[key]! as? String else{
            print("could not unwrap " + key)
            return ""
        }
        return info
    }
    
    func unwrapInt(dic: Dictionary<String, AnyObject>, key: String) -> Int{
        let str:String = String(dic[key]!)
        return Int(str)!
        
    }
    
    func fetchJSON(JsonURL: String){
        let data: NSData = NSData(contentsOfURL: NSURL(string: JsonURL)!)!
        dataDic = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
    }
    
    func parse(){
        
        self.day = unwrapInt(dataDic, key: "day")
        self.month = unwrapInt(dataDic, key: "month")
        self.year = unwrapInt(dataDic, key: "year")
        self.num = unwrapInt(dataDic, key: "num")
        self.title = unwrapStr(dataDic, key: "title")
        self.transcript = unwrapStr(dataDic, key: "transcript")
        self.alt = unwrapStr(dataDic, key: "alt")
        self.imageURL = unwrapStr(dataDic, key: "img")

    }
    
    init(JsonURL: String){
        
        day = Int()
        month = Int()
        year = Int()
        num = Int()
        title = String()
        alt = String()
        imageURL = String()
        transcript = String()
        fetchJSON(JsonURL)
        self.latestNum = unwrapInt(dataDic, key: "num")
        parse()
    }
    
}