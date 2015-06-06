//
//  Event.swift
//  Cerberus
//
//  Created by Yuki Iwanaga on 6/6/15.
//  Copyright (c) 2015 Wantedly, Inc. All rights reserved.
//

import Foundation

final class Event {
    var title: String = ""
    var location: String?
    
    var startAt: NSDate?
    var endAt: NSDate?
    
    var attendees: [User] = []
}