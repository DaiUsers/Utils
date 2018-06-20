# Generic Keychain Util


### ==config:==

- Target -> Capabilities -> keychain Sharing : Open

       if you want share the keychain with anothor project, add it's App ID.

- #import "YTKeychainUtils"

### ==API:==

class func


    //save account or password for key
    - +(BOOL)saveObject:(NSString *)obj forKey:(NSString *)key;



     //get account or password for key
     - +(NSString *)objectForKey:(NSString *)key;


    //delete a keychain item for key
    - +(BOOL)removeObjectForKey:(NSString *)key;



    //delete all keychain
    - +(BOOL)removeAll;


    //get all keychain_Obj<YTKeychainWrapper>
    - +(NSArray *)allKeychains;


    //get all keychain keys <NSString>
    - +(NSArray *)allKeys;


    //get all keychain values <NSString>
    - +(NSArray *)allValues;

