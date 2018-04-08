//
//  LogParser.swift
//  IA
//
//  Created by Kenny Schlagel on 4/7/18.
//  Copyright © 2018 Kenny Schlagel. All rights reserved.
//

import Foundation

protocol LogParserDelegate:class {
    func parsingDidSucceed(routes: [SequenceData])
    func parserWillStart(with count: Int)
    func parserDidParseElement(index: Int)
    //    func parsingDidFail()
}

class LogParser {
    var contents: [String.SubSequence]
    weak var delegate: LogParserDelegate?
    
    init?(url: URL) {
        guard let data = try? String(contentsOf: url, encoding: String.Encoding.utf8).split(separator: "\n") else { return nil}
        contents = data
    }
    
    // Try to keep this O(n)
    func parseLogForRouteSequences(patternMin: Int = 3) {
        var checker: [String: [String]] = [:] // checks an ip address to see if they have a sequence
        var routes: [String: SequenceData] = [:] // the final return data
        
        if contents.count > 0 {
            delegate?.parserWillStart(with: contents.count)
        }
        
        var element:Int = 0
        for entry in contents {
            let split = entry.split(separator: " ")
            let ip = String(split[0])
            let path = String(split[6])
            
            if checker[ip] != nil { // user has a key in checker
                // just gonna force unwrap this thing cause
                checker[ip]!.append(path)
                
                if checker[ip]!.count == patternMin {
                    
                    // format a key and add to route counter
                    let str = checker[ip]![0] + "," + checker[ip]![1] + "," + checker[ip]![2]
                    
                    if let alreadyExists = routes[str] {
                        routes[str]?.frequency = alreadyExists.frequency + 1
                    } else {
                        routes[str] = SequenceData(paths: str, frequency: 1)
                    }
                    
                    // reset the checker, because only 3 page sequences count
                    checker[ip]!.removeAll()
                }
            } else {
                // first time user has visited a path
                checker[ip] = [path]
            }
            
            delegate?.parserDidParseElement(index: element)
            element = element + 1
        }
        
        delegate?.parsingDidSucceed(routes: Array(routes.values))
    }
}
