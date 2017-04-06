#import <Foundation/Foundation.h>

@interface ProxyUtil : NSObject {}

+ (BOOL) networkReachable;
+ (void) showAlertUnexpectedError;
+ (void) showAlertNetworkUnreachable;
+ (NSString *)createSearchURL:(NSString*)query organism:(NSString*)org retstart:(NSString*)retstart retmax:(NSString*)retmax;
+ (NSString *)getParseError:(NSError*)parseError;

@end
