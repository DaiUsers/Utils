//
//  YTKeychainUtils.m
//  YTKeyChain
//
//  Created by wheng on 2018/3/28.
//  Copyright © 2018年 wheng. All rights reserved.
//

#import "YTKeychainUtils.h"
#import "YTKeychainWrapper.h"

@implementation YTKeychainUtils

+ (BOOL)saveObject:(NSString *)obj forKey:(NSString *)key {
	YTKeychainWrapper *keychain = [[YTKeychainWrapper alloc] initWithSevice:kYTServiceName account:key accessGroup:kYTAccessGroup];
	return [keychain savePassword:obj];
}

+ (NSString *)objectForKey:(NSString *)key {
	YTKeychainWrapper *keychain = [[YTKeychainWrapper alloc] initWithSevice:kYTServiceName account:key accessGroup:kYTAccessGroup];
	return [keychain readPassword];
}

+ (BOOL)removeObjectForKey:(NSString *)key {
	YTKeychainWrapper *keychain = [[YTKeychainWrapper alloc] initWithSevice:kYTServiceName account:key accessGroup:kYTAccessGroup];
	return [keychain deleteItem];
}

+ (BOOL)removeAll {
	return [YTKeychainWrapper deleteAllForSevice:kYTServiceName accessGroup:kYTAccessGroup];
}

+ (NSArray *)allKeychains {
	NSArray *tmpArray = [YTKeychainWrapper passwordItemsForSevice:kYTServiceName accessGroup:kYTAccessGroup];
	return tmpArray;
}

+ (NSArray *)allKeys {
	NSArray *tmpArray = [YTKeychainWrapper passwordItemsForSevice:kYTServiceName accessGroup:kYTAccessGroup];

	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:tmpArray.count];
	for (YTKeychainWrapper *item in tmpArray) {
		[keys addObject:item.account];
	}
	return keys;
}

+ (NSArray *)allValues {
	NSArray *tmpArray = [YTKeychainWrapper passwordItemsForSevice:kYTServiceName accessGroup:kYTAccessGroup];

	NSMutableArray *values = [NSMutableArray arrayWithCapacity:tmpArray.count];
	for (YTKeychainWrapper *item in tmpArray) {
		[values addObject: [item readPassword]];
	}
	return values;
}

@end
