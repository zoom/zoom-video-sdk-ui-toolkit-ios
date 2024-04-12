//
//  String+Extension.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import Foundation

extension String {
    var getDefaultName: String {
        let nameArray: [String] = self.components(separatedBy: " ")
        guard nameArray.count > 0, let firstInitial = nameArray[0].uppercased().first else { return "" }
        if nameArray.count > 1, let secondInitial = nameArray[1].uppercased().first {
            return "\(firstInitial)\(secondInitial)"
        }
        return "\(firstInitial)"
    }
}
