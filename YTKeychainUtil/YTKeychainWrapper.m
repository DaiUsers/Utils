//
//  YTKeychainItem.m
//  YTKeyChain
//
//  Created by wheng on 2018/3/28.
//  Copyright © 2018年 wheng. All rights reserved.
//

#import "YTKeychainWrapper.h"

@interface YTKeychainWrapper()

@property (nonatomic, copy)NSString *service;
@property (nonatomic, copy)NSString *accessGroup;

@end

@implementation YTKeychainWrapper

- (instancetype)initWithSevice:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup {
	if (self = [super init]) {
		_service = service;
		_account = account;
		_accessGroup = accessGroup;
	}
	return self;
}

- (BOOL)savePassword:(NSString *)password {
	NSData *encodePasswordData = [password dataUsingEncoding:NSUTF8StringEncoding];

	//
	NSString *originPassword = [self readPassword];

	if (originPassword) {
		NSMutableDictionary *updateAttributes = [NSMutableDictionary dictionary];
		[updateAttributes setObject:encodePasswordData forKey:(__bridge id)kSecValueData];
		NSMutableDictionary *query = [self keychainQueryWithService:_service account:_account accessGroup:_accessGroup];
			//	 You can update only a single keychain item at a time.
		OSStatus errorcode = SecItemUpdate(
										   (__bridge CFDictionaryRef)query,
										   (__bridge CFDictionaryRef)updateAttributes);
		NSAssert(errorcode == noErr, @"Couldn't update the Keychain Item.");
		return (errorcode == noErr);
	}
	else {
		NSMutableDictionary *query = [self keychainQueryWithService:_service account:_account accessGroup:_accessGroup];
		[query setObject:encodePasswordData forKey:(__bridge id)kSecValueData];

		OSStatus errorcode = SecItemAdd(
										(__bridge CFDictionaryRef)query,
										NULL);
//		NSAssert(errorcode == noErr, @"Couldn't add the Keychain Item.");
		return (errorcode == noErr);
	}
}

- (NSString *)readPassword {
	NSMutableDictionary *query = [self keychainQueryWithService:_service account:_account accessGroup:_accessGroup];

	//	Return the attributes of the first match only:
	[query setObject:(__bridge id)kSecMatchLimitOne
							 forKey:(__bridge id)kSecMatchLimit];
	//	Return the attributes of the keychain item ( the password is
	//		acquired in the secItemFormatToDictionary: method):
	[query setObject:(__bridge id)kCFBooleanTrue
							 forKey:(__bridge id)kSecReturnAttributes];
	//	 To acquire the password data from the keychain item,
	//	 first add the search key and class attribute required to obtain the password:
	[query setObject:(__bridge id)kCFBooleanTrue
						 forKey:(__bridge id)kSecReturnData];

	//	 Then call keychain Services to get the password:
	CFMutableDictionaryRef queryResult = nil;
	OSStatus keychainError = noErr;	 //
	keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)query,
										(CFTypeRef *)&queryResult);
	if (keychainError == noErr) {
			//	 Remove the kSecReturnData key; wo don't need it anymore:
		[query removeObjectForKey:(__bridge id)kSecReturnData];

			//	 Convert the password to an NSString and add it to the return dictionary:
		NSMutableDictionary *resultDic = (__bridge NSMutableDictionary *)queryResult;
		NSData *passwordData = resultDic[(__bridge id)kSecValueData];
		NSString *password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
		return password;
	}
		//	 Don't do anything if nothing is found.
	else if (keychainError == errSecItemNotFound) {
//		NSAssert(NO, @"Nothing was found in the keychain.\n");
		if (queryResult) CFRelease(queryResult);
	}
		//	 Any other error is unexpected.
	else
	  {
		NSAssert(NO, @"Serious error.\n");
		if (queryResult) CFRelease(queryResult);
	  }
	return nil;
}

- (BOOL)deleteItem {
		// Delete the existing item from the keychain.
	NSMutableDictionary *query = [self keychainQueryWithService:_service account:_account accessGroup:_accessGroup];

	//	 Delete the keychain item in preparation for resetting the values:
	OSStatus errorcode = SecItemDelete((__bridge CFDictionaryRef)query);
	//	NSAssert(errorcode == noErr, @"Problem deleting current keychain item.");
	return (errorcode == noErr || errorcode == errSecItemNotFound);

}

+ (BOOL)deleteAllForSevice:(NSString *)service accessGroup:(NSString *)accessGroup {
	NSMutableDictionary *query = [[[YTKeychainWrapper alloc] init] keychainQueryWithService:service account:nil accessGroup:accessGroup];
	[query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
	[query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
	[query setObject:(__bridge id)kCFBooleanFalse forKey:(__bridge id)kSecReturnData];
	CFMutableArrayRef queryResult = nil;
	OSStatus keychainError = noErr;	 //
	keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&queryResult);

	if (keychainError == noErr) {
			//	 Remove the kSecReturnData key; wo don't need it anymore:
		[query removeObjectForKey:(__bridge id)kSecReturnData];

		NSArray<NSDictionary *>*resultArray = (__bridge NSArray<NSDictionary *> *)queryResult;

		for (NSDictionary *result in resultArray) {

			NSString *account = result[(__bridge id)kSecAttrAccount];
			if (account) {
				NSMutableDictionary *query = [[[YTKeychainWrapper alloc] init] keychainQueryWithService:service account:account accessGroup:accessGroup];
			OSStatus errorcode = SecItemDelete((__bridge CFDictionaryRef)query);
			NSLog(@"删除结果:--%d",errorcode == noErr);
			}
		}
	}
		//	 Don't do anything if nothing is found.
	else if (keychainError == errSecItemNotFound) {
			//		NSAssert(NO, @"Nothing was found in the keychain.\n");
		if (queryResult) CFRelease(queryResult);
	}
		//	 Any other error is unexpected.
	else
	  {
		NSAssert(NO, @"Serious error.\n");
		if (queryResult) CFRelease(queryResult);
	  }
	return YES;
}

+ (NSArray<YTKeychainWrapper *> *)passwordItemsForSevice:(NSString *)service accessGroup:(NSString *)accessGroup {
	NSMutableDictionary *query = [[[YTKeychainWrapper alloc] init] keychainQueryWithService:service account:nil accessGroup:accessGroup];

	[query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
	[query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
	[query setObject:(__bridge id)kCFBooleanFalse forKey:(__bridge id)kSecReturnData];
	CFMutableArrayRef queryResult = nil;
	OSStatus keychainError = noErr;	 //
	keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&queryResult);

	if (keychainError == noErr) {
			//	 Remove the kSecReturnData key; wo don't need it anymore:
		[query removeObjectForKey:(__bridge id)kSecReturnData];

		NSArray<NSDictionary *>*resultArray = (__bridge NSArray<NSDictionary *> *)queryResult;

		NSMutableArray *passwordItems = [NSMutableArray array];
		for (NSDictionary *result in resultArray) {
			NSString *account = result[(__bridge id)kSecAttrAccount];
			if (account) {
				YTKeychainWrapper *item = [[YTKeychainWrapper alloc] initWithSevice:service account:account accessGroup:accessGroup];
				[passwordItems addObject:item];
			}
		}
		return passwordItems;
	}
		//	 Don't do anything if nothing is found.
	else if (keychainError == errSecItemNotFound) {
			//		NSAssert(NO, @"Nothing was found in the keychain.\n");
		if (queryResult) CFRelease(queryResult);
	}
		//	 Any other error is unexpected.
	else
	  {
		NSAssert(NO, @"Serious error.\n");
		if (queryResult) CFRelease(queryResult);
	  }
	return nil;
}


#pragma mark -- Private

- (NSMutableDictionary *)keychainQueryWithService:(NSString *)service account:(NSString *)account accessGroup:(NSString *)accessGroup {
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
	query[(__bridge id)kSecAttrService] = service;
	query[(__bridge id)kSecAttrAccount] = account;
	query[(__bridge id)kSecAttrAccessGroup] = accessGroup;
	query[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked;
	return query;
}

@end
