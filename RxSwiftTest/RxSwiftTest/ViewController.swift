//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by Youssra Outelli on 29/11/2018.
//  Copyright © 2018 Youssra Outelli. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


  private var tableView: UITableView!
  private let myArray = ["First", "Second", "Third"]

  override func viewDidLoad() {
    super.viewDidLoad()

    let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
    let displayWidth: CGFloat = self.view.frame.width
    let displayHeight: CGFloat = self.view.frame.height

    tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
    tableView.dataSource = self
    tableView.delegate = self
    self.view.addSubview(tableView)
  }


  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return myArray.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
    cell.textLabel!.text = "\(myArray[indexPath.row])"
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("Num: \(indexPath.row)")
    print("Value: \(myArray[indexPath.row])")
  }

}

