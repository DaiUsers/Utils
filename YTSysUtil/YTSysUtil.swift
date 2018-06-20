//
//  YTSysUtil.swift
//  YTJJYS
//
//  Created by wheng on 2018/4/12.
//  Copyright © 2018年 wheng. All rights reserved.
//

import Foundation

struct YTSysUtil {

	/// 拨打电话
	///
	/// - Parameter phoneNumber: 电话号码
	static func call(phoneNumber: String) {
		let callStr = "tel:" + phoneNumber
		if let url = URL.init(string: callStr) {
			let web = UIWebView.init()
			web.loadRequest(URLRequest.init(url: url))
			UIApplication.shared.keyWindow?.addSubview(web)
		}
	}
}
