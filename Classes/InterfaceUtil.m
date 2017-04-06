//
//  IntefaceUtil.m
//  biogene-client
//
//  Created by Benjamin on 7/9/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "InterfaceUtil.h"
#import "constants.h"

// class extension for private properties and methods
@interface InterfaceUtil ()

+ (NSString *)getFirstInList:(NSString*)list;

@end

@implementation InterfaceUtil

+ (NSString*)getGeneSymbol:(Gene*)gene {
	
	// return gene symbol if available
	if (gene.symbol != nil && [gene.symbol length] > 0) {
		return gene.symbol;
	}
	// if gene symbol is not available, try first alias
	else if (gene.aliases != nil && [gene.aliases length] > 0) {
		NSString *alias = [InterfaceUtil getFirstInList:gene.aliases];
		if (alias != nil) {
			return alias;
		}
	}
	// if alias is not available, try other designation
	else if (gene.designations != nil && [gene.designations length] > 0) {
		NSString *designation = [InterfaceUtil getFirstInList:gene.designations];
		if (designation != nil) {
			if (![designation isEqualToString:kHypotheticalProtein]) {
				return designation;
			}
			else {
				// combine locus tag with designation
				if (gene.tag != nil && [gene.tag length] > 0) {
					return [NSString stringWithFormat:@"%@ %@", gene.tag, designation];
				}
			}
		}
	}
	
	// made it here
	return nil;
}

+ (NSString*)getPaginationString:(BOOL)geneResults start:(NSString*)start end:(NSString*)end total:(NSString*)total {
	
	NSString *paginationStr = (geneResults) ? [NSString stringWithFormat:kGeneResultsPaginationLabel] : [NSString stringWithFormat:kRIFResultsPaginationLabel];
	paginationStr = [paginationStr stringByReplacingOccurrencesOfString:kPaginationStartPlaceHolder withString:start];
	paginationStr = [paginationStr stringByReplacingOccurrencesOfString:kPaginationEndPlaceHolder withString:end];
	paginationStr = [paginationStr stringByReplacingOccurrencesOfString:kPaginationTotalPlaceHolder withString:total];
	
	// outta here
	return paginationStr;
}

+ (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation prefs:(Prefs*)prefs {
	return (prefs.enableAutorotation && (interfaceOrientation == UIInterfaceOrientationPortrait ||
										 interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
										 interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

+ (NSString *)getFirstInList:(NSString*)list {

	NSArray *components = [list componentsSeparatedByString:kAliasesDesignationsDelimiter];
	if ([components count] > 0) {
		NSString *first = [components objectAtIndex:0];
		if ([first length] > 0) {
			return first;
		}
	}
	
	// made it here
	return nil;
}

@end

