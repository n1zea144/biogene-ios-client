//
//  ProxyUtil.m
//  biogene-client
//
//  Created by Benjamin on 7/9/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ProxyUtil.h"
#import "constants.h"
#import "Reachability.h"

// class extension for private properties and methods
@interface ProxyUtil ()
	+ (NSString *) encodeString:(NSString*)str;
@end 

@implementation ProxyUtil

+ (BOOL) networkReachable {
	//[[Reachability sharedReachability] setHostName:kBioGENEProxyServer];
	//NetworkStatus remoteHostStatus = [[Reachability sharedReachability] remoteHostStatus];
	NetworkStatus internetConnectionStatus = [[Reachability sharedReachability] internetConnectionStatus];
	NetworkStatus localWiFiConnectionStatus = [[Reachability sharedReachability] localWiFiConnectionStatus];
	return ( (internetConnectionStatus != NotReachable) || (localWiFiConnectionStatus != NotReachable));
}

+ (void) showAlertNetworkUnreachable {
	
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kReachabilityAlertTitle message:kReachabilityAlertMessage
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

+ (void) showAlertUnexpectedError {
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kUnexpectedErrorTitle message:kUnexpectedError
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

+ (NSString *)createSearchURL:(NSString*)query organism:(NSString*)org retstart:(NSString*)retstart retmax:(NSString*)retmax {

	NSString *searchURL = [NSString stringWithFormat:kBioGENEProxyURL];
	NSString *searchText = [ProxyUtil encodeString:query];
	searchURL = [searchURL stringByReplacingOccurrencesOfString:kQueryPlaceHolder withString:searchText];
	NSString *organism = [ProxyUtil encodeString:org];
	searchURL = [searchURL stringByReplacingOccurrencesOfString:kOrganismPlaceHolder withString:organism];
	searchURL = [searchURL stringByReplacingOccurrencesOfString:kRetStartPlaceHolder withString:retstart];
	searchURL = [searchURL stringByReplacingOccurrencesOfString:kRetMaxPlaceHolder withString:retmax];
	
	// outta here
	return searchURL;
}

+ (NSString *) encodeString:(NSString*)str {

	// encode % first since we will be encode with it below
	NSString *toReturn = [str stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];

	// reserved chars
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"$" withString:@"%24"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
	
	// unsafe chars
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"<" withString:@"%3C"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@">" withString:@"%3E"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"{" withString:@"%7B"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"}" withString:@"%7D"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"|" withString:@"%7C"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"\\" withString:@"%5C"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"^" withString:@"%5E"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"~" withString:@"%7E"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"[" withString:@"%5B"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"]" withString:@"%5D"];
	toReturn = [toReturn stringByReplacingOccurrencesOfString:@"`" withString:@"%60"];
	
	// outta here
	return toReturn;
}

+ (NSString *)getParseError:(NSError*)parseError {
	
	NSString *toReturn = [NSString stringWithFormat:kUnexpectedError];
	//NSString *localizedDescription = [parseError localizedDescription];
	//if (localizedDescription != nil) {
	//	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:@"%@.  ", localizedDescription]];
	//}
	//NSString *localizedFailureReason = [parseError localizedFailureReason];
	//if (localizedFailureReason != nil) {
	//	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:@"%@.  ", localizedFailureReason]];
	//}
	//NSString *localizedRecoverySuggestion = [parseError localizedRecoverySuggestion];
	//if (localizedRecoverySuggestion != nil) {
	//	toReturn = [toReturn stringByAppendingString:[NSString stringWithFormat:@"%@.  ", localizedRecoverySuggestion]];
	//}
	return toReturn;
}

@end

