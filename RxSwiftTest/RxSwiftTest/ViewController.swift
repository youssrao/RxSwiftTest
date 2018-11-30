//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by Youssra Outelli on 29/11/2018.
//  Copyright © 2018 Youssra Outelli. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    print("------Observables-------")
    Observables()
    print("------Subjects----------")
    Subjects()
    print("------PublisherSubject----------")
    test()
    print("------Transformation: Map----------")
    map()
    print("------Transformation: FlatMap----------")
    flatMap()
    print("------Transformation: Scan----------")
    scan()
    print("------Transformation: Filter----------")
    filter()
    print("------Transformation: Distinct until changed----------")
    distinct()
    print("------Combine: StartWith----------")
    startWith()
    print("------Combine: Merge----------")
    merge()
    print("------Combine: Zip----------")
    zip()
    print("------Side Effects: do on ----------")
    doOn()
    print("------Schedulers----------")
    schedulers()
  }



  func Observables() {
    //    //Creating a DisposeBag so subscription will be canceled correctly
    //    let bag = DisposeBag()
    //
    //    //Creating an Observable Sequence that emits a String value
    //    let observable = Observable.just("Hello Rx!")
    //
    //    //Creating a subscription just for next events
    //    let sub = observable.subscribe (onNext: {
    //      print($0)
    //    })
    //
    //    //Adding the Subscription to a Dispose Bag
    //    sub.disposed(by: bag)

    let helloSequence = Observable.just("Hello Rx")
    let fibonacciSequence = Observable.from([0, 1, 2, 3, 4, 5, 6, 7, 8])
    let dictSequence = Observable.from([1: "Hello", 2: "World"])

    let subscription = helloSequence.subscribe { event in
      switch event {
      case .next(let value):
        print(value)
      case .error(let error):
        print(error)
      case .completed:
        print("completed")
      }
    }
  }


  func Subjects() {

    //create an actual PublishSubject instance
    let bag = DisposeBag()
    var publishSubject = PublishSubject<String>()

    //You can add new Values to that sequence by using the onNext() function. onCompleted() will complete the sequence
    //and onError(error) will result in emitting an error event.
    publishSubject.onNext("Hello")
    publishSubject.onNext("World")




    let subscription1 = publishSubject.subscribe(onNext: {
      print("Sub 1: \($0)")
    }).disposed(by: bag)

    //Subscription1 receives these 3 events, Subscription2 won't
    publishSubject.onNext("Hello")
    publishSubject.onNext("Again")
    publishSubject.onNext("dag")

    //Sub2 will not get "Hello", "Again", "sub1" because it subscribed later
    let subscription2 = publishSubject.subscribe(onNext: {
      //print(#line,$0)
      print("Sub 2: \($0)")
    })

    publishSubject.onNext("Both subscriptions receive this message")
    publishSubject.onNext("doei")
  }


  class Publisher {
     var listeners = [(String) -> Void]()
    private var history = [String]()

    func addListener(_ listener: @escaping (String) -> Void) {
      listeners.append(listener)
      for h in history {
        listener(h)
      }
    }

    func publish(_ string: String) {
      history.append(string)

      for listener in listeners {
        listener(string)
      }
    }
  }

  func test() {
    let p = Publisher()
    let one: (String) -> Void = { str in
      print("1: \(str)")
    }
    p.listeners.append(one)
    p.publish("Hello")
    p.publish(",")

    p.listeners.append({ str in print("2: \(str)")})
    p.publish(" ")
    p.publish("World")
  }



  func map() {
    //Map transforms Elements emitted from an observable Sequence, before they reach their subscribers
    Observable<Int>.of(1, 2, 3, 4, 5, 6, 7, 8).map { value in
      return value * 10
      }.subscribe(onNext: {
        print($0)
      })
  }


  func flatMap() {
    //FlatMap merges the emission of the resulting Observables and emitting these merged results as its own sequence.
    let sequence1 = Observable<Int>.of(1, 2)
    let sequence2 = Observable<Int>.of(1, 2)

    let sequenceOfSequences = Observable.of(sequence1, sequence2)

    sequenceOfSequences.flatMap { return $0 }.subscribe(onNext: {
      print($0)
    })
  }


  func scan() {
    //Scan starts with an initial seed value and is used to aggregate values just like reduce.
    Observable.of(1, 2, 3, 4, 5).scan(0) { seed, value in
      return seed + value
      }.subscribe(onNext: {
        print($0)
      })
  }


//  func buffer() {
//    //transforms an Observable that emits items into an Observable that emits buffered collection of those items.
//    (SequenceThatEmitsWithDifferentIntervals)
//      .buffer(timeSpan: 150, count: 3, scheduler:s)
//      .subscribe(onNext: {
//        print($0)
//      })
//  }



  func filter() {
    //you define a condition that needs to be passed and if the condition is fulfilled a next event will be emitted to
    //its subscriber

    Observable.of(2, 30, 22, 5, 60, 78, 9).filter{$0 < 10}.subscribe(onNext: {
      print($0)
    })
  }


  func distinct() {
    //if you just want to emit next Events if the value changed from previous ones you need ot use distinctUntilChanged
    Observable.of(1, 2, 2, 1, 1, 3, 3, 2).distinctUntilChanged().subscribe(onNext: {
      print($0)
    })
  }



  func startWith() {
    //an Observable to emit a specific sequence of items before it begins emitting the items normally expected from it
    Observable.of(2, 3).startWith(1).subscribe(onNext: {
      print($0)
    })
  }

  func merge() {
    //combine the output of multiple Observables so that they act like a single Observable
    let publish1 = PublishSubject<Int>()
    let publish2 = PublishSubject<Int>()

    Observable.of(publish1, publish2).merge().subscribe(onNext: {
      print($0)
    })

    publish1.onNext(20)
    publish1.onNext(40)
    publish1.onNext(60)
    publish2.onNext(1)
    publish1.onNext(80)
    publish2.onNext(2)
    publish1.onNext(100)
  }


  func zip() {
    //You use the Zip method if you want to merge items emitted by different observable sequences to one observable sequence.
    //Zip will operate in strict sequence, so the first two elements emitted by Zip will be the first element of the first
    //sequence and the first element of the second sequence combined. Keep also in Mind that Zip will only emit as many
    //items as the number of items emitted of the source Observables that emits the fewest items.
    let a = Observable.of(1, 2, 3, 4, 5)
    let b = Observable.of("a", "b", "c", "d")

    Observable.zip(a, b){ return ($0, $1) }.subscribe {
      print($0)
    }
  }

    func doOn() {
      //If you want to register callbacks that will be executed when certain events take place on an
      //Observable Sequence you need to use the doOn Operator
      //do(onNext:) - if you want to do something just if a next event happened
      //do(onError:) - if errors will be emitted and
      //do(onCompleted:) - if the sequence finished successfully.
      Observable.of(1, 2, 3, 4, 5).do(onNext: {
        $0 * 10 //This has no effect on the actual subscription
      }).subscribe(onNext: {
        print($0)
      })
    }


  func schedulers() {
    //Here is a code snippet that shows you how to observe something concurrently on a background queue und subscribe on the main-queue.

    let publish1 = PublishSubject<Int>()
    let publish2 = PublishSubject<Int>()

    let concurrentScheduler = ConcurrentDispatchQueueScheduler(qos: .background)

    Observable.of(publish1, publish2)
              .observeOn(concurrentScheduler)
              .merge()
              .subscribeOn(MainScheduler())
      .subscribe(onNext: {
        print($0)
      })

    publish1.onNext(20)
    publish2.onNext(40)
  }
}


















  //MARK: - TableView
  //var tableView: UITableView!
  //let myArray = ["First", "Second", "Third"]
  //
  //override func viewDidLoad() {
  //  super.viewDidLoad()
  //
  //  let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
  //  let displayWidth: CGFloat = self.view.frame.width
  //  let displayHeight: CGFloat = self.view.frame.height
  //
  //  tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
  //  tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
  //  tableView.dataSource = self
  //  tableView.delegate = self
  //  self.view.addSubview(tableView)
  //}
  //
  //
  //func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  //  return myArray.count
  //}
  //
  //func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  //  let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
  //  cell.textLabel!.text = "\(myArray[indexPath.row])"
  //  return cell
  //}
  //
  //func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  //  print("Num: \(indexPath.row)")
  //  print("Value: \(myArray[indexPath.row])")
  //}
  //

