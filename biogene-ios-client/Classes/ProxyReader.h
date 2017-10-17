#import <Foundation/Foundation.h>

@class Gene;
@class RIF;

@interface ProxyReader : NSObject <NSXMLParserDelegate> {

	NSString *parserCode;
	
@private
	RIF *currentRIF;
	Gene *currentGene;
	BOOL storingProperty;
	NSString *serverReturnCode;
	NSMutableString *contentOfCurrentGeneProperty;
}

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error serverReturnCode:(NSString **)code;

@end
