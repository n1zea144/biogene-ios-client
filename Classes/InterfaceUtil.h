#import <Foundation/Foundation.h>
#import "Prefs.h"
#import "Gene.h"

@interface InterfaceUtil : NSObject {}

+ (NSString*)getGeneSymbol:(Gene*)gene;
+ (NSString*)getPaginationString:(BOOL)geneResults start:(NSString*)start end:(NSString*)end total:(NSString*)total;
+ (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation prefs:(Prefs*)prefs;

@end
