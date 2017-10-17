#import "Prefs.h"
#import "constants.h"

@implementation Prefs

@synthesize organism;
@synthesize rifsPerPage;
@synthesize enableAutorotation;
@synthesize retMax;

- (void)dealloc {
	[self.organism release];
	[self.rifsPerPage release];
	[self.retMax release];
	[super dealloc];
}

- (NSInteger)getRifsPerPageAsInteger {
	if ([self.rifsPerPage isEqualToString:k25RIFsPerPage]) {
		return 25;
	}
	else if ([self.rifsPerPage isEqualToString:k50RIFsPerPage]) {
		return 50;
	}
	else if ([self.rifsPerPage isEqualToString:k75RIFsPerPage]) {
		return 75;
	}
	else if ([self.rifsPerPage isEqualToString:k100RIFsPerPage]) {
		return 100;
	}
	else if ([self.rifsPerPage isEqualToString:k200RIFsPerPage]) {
		return 200;
	}
	else {
		return 100;
	}
}

- (NSString *)getRetMaxAbbreviated {
	if ([self.retMax isEqualToString:k5RecordsPerPage]) {
		return [NSString stringWithFormat:@"5"];
	}
	else if ([self.retMax isEqualToString:k10RecordsPerPage]) {
		return [NSString stringWithFormat:@"10"];
	}
	else if ([self.retMax isEqualToString:k25RecordsPerPage]) {
		return [NSString stringWithFormat:@"25"];
	}
	else if ([self.retMax isEqualToString:k50RecordsPerPage]) {
		return [NSString stringWithFormat:@"50"];
	}
	else if ([self.retMax isEqualToString:k100RecordsPerPage]) {
		return [NSString stringWithFormat:@"100"];
	}
	else {
		return [NSString stringWithFormat:@"25"];
	}
}

- (NSInteger)getRetMaxAsInteger {
	if ([self.retMax isEqualToString:k5RecordsPerPage]) {
		return 5;
	}
	else if ([self.retMax isEqualToString:k10RecordsPerPage]) {
		return 10;
	}
	else if ([self.retMax isEqualToString:k25RecordsPerPage]) {
		return 25;
	}
	else if ([self.retMax isEqualToString:k50RecordsPerPage]) {
		return 50;
	}
	else if ([self.retMax isEqualToString:k100RecordsPerPage]) {
		return 100;
	}
	else {
		return 25;
	}
}

@end