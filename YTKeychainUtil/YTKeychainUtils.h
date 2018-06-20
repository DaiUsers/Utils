//
//  YTKeychainUtils.h
//  YTKeyChain
//
//  Created by wheng on 2018/3/28.
//  Copyright © 2018年 wheng. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kYTServiceName = @"YT.wheng.service";
static NSString * const kYTAccessGroup = nil;

@class YTKeychainWrapper;
@interface YTKeychainUtils : NSObject

+ (BOOL)saveObject:(NSString *)obj forKey:(NSString *)key;

+ (nullable NSString *)objectForKey:(NSString *)key;

+ (BOOL)removeObjectForKey:(NSString *)key;

+ (BOOL)removeAll;

+ (nullable NSArray *)allKeychains;

+ (nullable NSArray *)allKeys;

+ (nullable NSArray *)allValues;

@end
