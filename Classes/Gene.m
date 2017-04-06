#import "Gene.h"

@implementation Gene

@synthesize symbol;
@synthesize tag;
@synthesize summary;
@synthesize organism;
@synthesize description;
@synthesize rifList;
@synthesize aliases;
@synthesize designations;
@synthesize chromosome;
@synthesize location;
@synthesize mim;
@synthesize geneID;

- (id)init {
	if ((self = [super init])) {
		self.rifList = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
	[self.symbol release];
	[self.tag release];
	[self.summary release];
	[self.organism release];
	[self.description release];
	[self.rifList release];
	[self.aliases release];
	[self.designations release];
	[self.chromosome release];
	[self.location release];
	[self.mim release];
	[self.geneID release];
	[super dealloc];
}

@end

