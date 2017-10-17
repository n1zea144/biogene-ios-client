#import <Foundation/Foundation.h>

@interface Prefs : NSObject {

@private    
	NSString *organism;
	NSString *rifsPerPage;
	BOOL enableAutorotation;
	NSString *retMax;
}

@property (nonatomic, retain) NSString *organism;
@property (nonatomic, retain) NSString *rifsPerPage;
@property BOOL enableAutorotation;
@property (nonatomic, retain) NSString *retMax;
@property (readonly, getter=getRifsPerPageAsInteger) NSInteger rifsPerPageInteger;
@property (readonly, getter=getRetMaxAbbreviated) NSString* retMaxAbbr;
@property (readonly, getter=getRetMaxAsInteger) NSInteger retMaxInteger;

@end
