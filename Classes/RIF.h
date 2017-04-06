#import <Foundation/Foundation.h>

@interface RIF : NSObject {

@private    
    NSString *rif;
	NSString *pubmedID;
}

@property (nonatomic, retain) NSString *rif;
@property (nonatomic, retain) NSString *pubmedID;

@end
