
//
//  YTPlistData.swift
//  JJEnterprise
//
//  Created by wheng on 2018/5/31.
//  Copyright © 2018年 wheng. All rights reserved.
//

import Foundation

class YTPlistData {
	class func writeArrayData(sourceArray: NSArray, path: String) -> Bool {

		let manager = FileManager.default
		let exist = manager.fileExists(atPath: path)
		if exist == false {
			let _ = manager.createFile(atPath: path, contents: nil, attributes: nil)
		}
		let res = sourceArray.write(toFile: path, atomically: true)
		return res
	}

	class func readArrayData(path: String) -> NSArray? {
		let array = NSArray.init(contentsOfFile: path)
		return array
	}
}
