//
//  YTSandboxPath.swift
//  YTArchiverTest
//
//  Created by 王恒 on 2018/4/11.
//  Copyright © 2018年 wheng. All rights reserved.
//

import Foundation


struct YTSandboxPath {
    
    /// Document
    /// 用于保存应用运行时生成的需要持久化、非常大的或者需要频繁更新的数据，iTunes会自动备份该目录
    ///
    /// - Parameter component: fileName
    /// - Returns: filePath nullable
    static func yt_documentByAppendPath(component: String) -> String? {
        return self.getSandboxPathIn(directory: .documentDirectory, component: component)
    }
    
    /// Library
    /// 用于存储程序的默认设置和其他状态信息，iTunes会自动备份该目录。
    /// Libaray/下主要有两个文件夹：Libaray/Caches和Libaray/Preferences
    ///
    /// - Parameter component: fileName
    /// - Returns: filePath nullabel
    static func yt_libraryByAppendPath(component: String) -> String? {
        return self.getSandboxPathIn(directory: .libraryDirectory, component: component)
    }
    
    /// Library/Caches
    /// 存放缓存文件，iTunes不会备份此目录，此目录下文件不会在应用退出删除，一般存放体积比较大，不是很重要的资源。
    ///
    /// - Parameter component: fileName
    /// - Returns: filePath nullable
    static func yt_cachesByAppendPath(component: String) -> String? {
        return self.getSandboxPathIn(directory: .cachesDirectory, component: component)
    }
    
    /// Library/Preferences
    /// 保存应用的所有偏好设置，ios的Settings（设置）应用会在该目录中查找应用的设置信息，iTunes会自动备份该目录。
    ///
    ///
    /// - Parameter component: fileName
    /// - Returns: filePath nullable
    static func yt_preferencesByAppendPath(component: String) -> String? {
        return self.getSandboxPathIn(directory: .preferencePanesDirectory, component: component)
    }
    
    /// Temporary
    /// 保存应用运行时所需的临时数据，使用完毕后再将相应的文件从该目录删除
    /// 应用没有运行时，系统也可能会自动清理该目录下的文件，iTunes不会同步该目录，iPhone重启时该目录下的文件会丢失。
    ///
    /// - Parameter component: fileName
    /// - Returns: filePath nullable
    static func yt_tempByAppendPath(component: String) -> String? {
        let temp = NSTemporaryDirectory()
        let filePath = temp.appendingFormat(component)
        return filePath
    }
    
    /// 根据不同文件夹类型，获取路径
    ///
    /// - Parameters:
    ///   - directory: 文件夹类型
    ///   - component: fileName
    /// - Returns: filePath nullable
    private static func getSandboxPathIn(directory: FileManager.SearchPathDirectory, component: String) -> String? {
        let directorys = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)
        if let directory = directorys.first {
            let filePath = directory.appendingFormat("/" + component)
            return filePath
        }
        assert(directorys.first != nil, component + " can not found in the directory")
        return nil
    }
}
