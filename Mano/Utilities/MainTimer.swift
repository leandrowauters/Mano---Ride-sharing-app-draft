//
//  MainTimer.swift
//  Mano
//
//  Created by Leandro Wauters on 7/30/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation

class MainTimer {
    
    let timeInterval: TimeInterval
    public var time = 0.0
    
    public var sharedTimer = String()
    
    
    
    
    var currentBackgroundDate = NSDate()
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    static var shared = MainTimer(timeInterval: 1)
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    
    var eventHandler: (() -> Void)?
    
    enum State {
        case suspended
        case resumed
        case restated
        case stopped
    }
    
    private var state: State = .suspended
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        resume()
        eventHandler = nil
    }
    
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
    
    func restartTimer(){
        if state == .resumed{
            return
        }
        let difference = self.currentBackgroundDate.timeIntervalSince(NSDate() as Date)
        let timeSince = abs(difference)
        time += timeSince
        resume()
    }
    
    
    func pauseTime(){
        suspend()
        currentBackgroundDate = NSDate()
    }
    
    func runTimer (duration: Int){
        eventHandler = {
            self.time += 1
        }
        resume()
    }
    
    func stopTimer() {
        suspend()
        time = 0.0
    }
    
    
    
    
    
    static func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        if time >= 3600{
            return "\(hours) hrs , \(minutes) Min"
        } else {
           return "\(minutes) Mins"
        }
    }
}
