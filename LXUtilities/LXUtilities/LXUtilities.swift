//
//  LXUtilities.swift
//
//  Created by 从今以后 on 16/1/2.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation

func printLog(items: Any, file: String = __FILE__, line: Int = __LINE__, function: String = __FUNCTION__) {
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)] \(function)\n", items, separator: "")
    #endif
}
