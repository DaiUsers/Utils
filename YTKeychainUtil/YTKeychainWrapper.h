//
//  YTKeychainItem.h
//  YTKeyChain
//
//  Created by wheng on 2018/3/28.
//  Copyright © 2018年 wheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface YTKeychainWrapper : NSObject

@property (nonatomic, copy)NSString *account;

- (instancetype)initWithSevice:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup;

- (NSString *)readPassword;

- (BOOL)savePassword:(NSString *)password;

- (BOOL)deleteItem;

+ (NSArray<YTKeychainWrapper *> *)passwordItemsForSevice:(NSString *)service accessGroup:(NSString *)accessGroup;

+ (BOOL)deleteAllForSevice:(NSString *)service accessGroup:(NSString *)accessGroup;

@end
