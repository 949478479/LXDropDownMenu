//
//  LXUtilities.swift
//
//  Created by 从今以后 on 16/1/2.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation

func printLog(items: Any, file: String = #file, line: Int = #line, function: String = #function) {
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)] \(function)\n", items, separator: "")
    #endif
}
