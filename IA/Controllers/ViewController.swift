//
//  ViewController.swift
//  IA
//
//  Created by Kenny Schlagel on 4/7/18.
//  Copyright © 2018 Kenny Schlagel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tableData = [Int: [SequenceData]]()
    var maxFrequency: Int = 0

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let fileURL = Bundle.main.url(forResource: "IA", withExtension: "log") else {
            fatalError("URL Init Failed") // for demo
        }
        
        guard let parser = LogParser(url: fileURL) else {
            fatalError("Log Init Failed") // for demo
        }
        
        parser.delegate = self
        parser.parseLogForRouteSequences()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: LogParserDelegate
extension ViewController: LogParserDelegate {
    func parsingDidSucceed(routes: [SequenceData], maxFrequency: Int) {

        self.maxFrequency = maxFrequency // store the max

        for route in routes {
            if tableData[maxFrequency - route.frequency] != nil {
                tableData[maxFrequency - route.frequency]?.append(route)
            } else {
                tableData[maxFrequency - route.frequency] = [route]
            }
         }
        tableView.reloadData()
    }
    
    func parserWillStart(with: Int) {
        //load progress indicator
        print("going to start \(with) elements")
    }
    
    func parserDidParseElement(index: Int) {
        // update progress indicator
        print("parsed element \(index)")
    }
}

// MARK: UITableViewDataSource & Delegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Frequency \(maxFrequency - section)"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: LogCellTableViewCell.reuseIdentifier) as? LogCellTableViewCell {
            let routeData = tableData[indexPath.section]![indexPath.row]
            cell.routeLabel.text = routeData.paths.replacingOccurrences(of: ",", with: "\n")
            cell.routeLabel.sizeToFit()
            cell.countLabel.text = "\(routeData.frequency)"
            return cell
        }
        return UITableViewCell()
    }
}
