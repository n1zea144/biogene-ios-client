#import "RIF.h"

@implementation RIF

@synthesize rif;
@synthesize pubmedID;

- (void)dealloc {
	[self.rif release];
	[self.pubmedID release];
	[super dealloc];
}

@end

