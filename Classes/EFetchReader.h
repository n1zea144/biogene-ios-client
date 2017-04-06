#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@class Gene;
@class RIF;

@interface EFetchReader : NSObject {

@private
	// reference to the libxml parser context
    xmlParserCtxtPtr context;
    NSURLConnection *rssConnection;
    // overall state of the parser, used to exit the run loop.
    BOOL done;
    // state variable used to determine whether or not to ignore a given XML element
    BOOL parsingAGene;
    // the following state variables deal with getting character data from XML elements. This is a potentially expensive 
    // operation. The character data in a given element may be delivered over the course of multiple callbacks, so that
    // data must be appended to a buffer. The optimal way of doing this is to use a C string buffer that grows exponentially.
    // When all the characters have been delivered, an NSString is constructed and the buffer is reset.
    BOOL storingCharacters;
    NSMutableData *characterBuffer;
    // a reference to the current gene/gene rif the parser is working with.
    Gene *currentGene;
	RIF *currentGeneRIF;
    // the number of parsed songs is tracked so that the autorelease pool for the parsing thread can be periodically
    // emptied to keep the memory footprint under control. 
#ifdef PARSER_POOL
    NSUInteger createdStringCount;
    NSAutoreleasePool *downloadAndParsePool;
#endif
	// other misc vars
	NSString *geneSymbol;
	BOOL lookForRIFs;
	BOOL lookForMIM;
	BOOL lookForLocusLink;
	BOOL lookForPubMedID;
}

- (void)parseXMLFileAtURL:(NSURL *)url parseError:(NSError **)error geneSymbol:(NSString *)symbol;

@end
