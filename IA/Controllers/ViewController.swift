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
    
    var spinner: UIActivityIndicatorView?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set up spinner
        if spinner == .none {
            let spinna = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            spinna.frame = CGRect(x: self.view.center.x - 15, y: self.view.center.y - 20, width: 40.0, height: 40.0)
            spinna.transform = CGAffineTransform(scaleX: 2, y: 2)
            spinna.startAnimating()
            view.addSubview(spinna)
            
            spinner = spinna
        }
        
        guard let fileURL = Bundle.main.url(forResource: "IA", withExtension: "log") else {
            fatalError("URL Init Failed") // for demo
        }
        
        guard let parser = LogParser(url: fileURL) else {
            fatalError("Log Init Failed") // for demo
        }
        
        parser.delegate = self
        DispatchQueue.global(qos: .background).async { [p = parser] in
            p.parseLogForRouteSequences()
        }
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
        
        DispatchQueue.main.async { [tv = tableView, spin = spinner] in
            tv?.reloadData()
            spin?.stopAnimating()
            spin?.alpha = 0.0
        }
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.black
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 10, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0) ?? UIFont.boldSystemFont(ofSize: 16.0)
        headerLabel.textColor = UIColor.white
        headerLabel.text = "Frequency \(maxFrequency - section)"
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
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
