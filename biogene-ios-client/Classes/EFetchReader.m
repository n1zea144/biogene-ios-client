#import "EFetchReader.h"
#import "Gene.h"
#import "RIF.h"
#import <libxml/tree.h>
#import <UIKit/UIKit.h>

// function prototypes for SAX callbacks.
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void	charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

// the handler struct has positions for a large number of callback functions. if NULL is supplied at a given position,
// that callback functionality won't be used. refer to libxml documentation at http://www.xmlsoft.org for more information
// about the SAX callbacks.
static xmlSAXHandler simpleSAXHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    NULL,                       /* startDocument */
    NULL,                       /* endDocument */
    NULL,                       /* startElement*/
    NULL,                       /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    NULL,                       /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             //
    NULL,
    startElementSAX,            /* startElementNs */
    endElementSAX,              /* endElementNs */
    NULL,                       /* serror */
};

// xml element name constants (names and lengths, lengths include null)
static const char *kEntrezgene = "Entrezgene";
static const NSUInteger kEntrezgene_length = 11;
static const char *kSubsource_name = "SubSource_name";
static const NSUInteger kSubsource_name_length = 15;
static const char *kGeneref_maploc = "Gene-ref_maploc";
static const NSUInteger kGeneref_maploc_length = 16;
static const char *kOrgref_taxname = "Org-ref_taxname";
static const NSUInteger kOrgref_taxname_length = 16;
static const char *kGeneref_locus = "Gene-ref_locus";
static const NSUInteger kGeneref_locus_length = 15;
static const char *kGeneref_desc = "Gene-ref_desc";
static const NSUInteger kGeneref_desc_length = 14;
static const char *kEntrezgene_summary = "Entrezgene_summary";
static const NSUInteger kEntrezgene_summary_length = 19;
static const char *kGeneref_syn = "Gene-ref_syn_E";
static const NSUInteger kGeneref_syn_length = 15;
static const char *kProtref_name = "Prot-ref_name_E";
static const NSUInteger kProtref_name_length = 16;
static const char *kGene_commentary_type = "Gene-commentary_type";
static const NSUInteger kGene_commentary_type_length = 21;
static const char *kGene_commentary_text = "Gene-commentary_text";
static const NSUInteger kGene_commentary_text_length = 21;
static const char *kPubMed_id = "PubMedId";
static const NSUInteger kPubMed_id_length = 9;
static const char *kDBTag = "Dbtag_db";
static const NSUInteger kDBTag_length = 9;
static const char *kObjectID = "Object-id_id";
static const NSUInteger kObjectID_length = 13;
static const char *kGene_source_src = "Gene-source_src";
static const NSUInteger kGene_source_src_length = 16;
static const char *kGene_source_int = "Gene-source_src-int";
static const NSUInteger kGene_source_int_length = 20;

#ifdef PARSER_POOL
// autorelease bool frequency
static const NSUInteger kAutoreleasePoolPurgeFrequency = 1000;
#endif

// class extension for private properties and methods
@interface EFetchReader ()

@property BOOL storingCharacters;
@property (nonatomic, retain) NSMutableData *characterBuffer;
@property BOOL done;
@property BOOL parsingAGene;
@property (nonatomic, retain) Gene *currentGene;
@property (nonatomic, retain) RIF *currentGeneRIF;
@property (nonatomic, retain) NSURLConnection *rssConnection;
#ifdef PARSER_POOL
// The autorelease pool property is assign because autorelease pools cannot be retained.
@property NSUInteger createdStringCount;
@property (nonatomic, assign) NSAutoreleasePool *downloadAndParsePool;
#endif
@property (nonatomic, retain) NSString *geneSymbol;
@property BOOL lookForRIFs;
@property BOOL lookForMIM;
@property BOOL lookForLocusLink;
@property BOOL lookForPubMedID;

#ifdef PARSER_POOL
- (void)releasePool;
#endif
- (void)finishedCurrentGene;

@end

@implementation EFetchReader
#ifdef PARSER_POOL
@synthesize rssConnection, done, parsingAGene, storingCharacters, currentGene, currentGeneRIF, createdStringCount, characterBuffer, downloadAndParsePool, geneSymbol, lookForRIFs, lookForMIM, lookForLocusLink, lookForPubMedID;
#else
@synthesize rssConnection, done, parsingAGene, storingCharacters, currentGene, currentGeneRIF, characterBuffer, geneSymbol, lookForRIFs, lookForMIM, lookForLocusLink, lookForPubMedID;
#endif

#pragma mark parser methods

- (void)parseXMLFileAtURL:(NSURL *)url parseError:(NSError **)error geneSymbol:(NSString *)symbol {	

	// init some members
	self.geneSymbol = symbol;
#ifdef PARSER_POOL
	self.downloadAndParsePool = [[NSAutoreleasePool alloc] init];
#endif
	done = NO;
	self.characterBuffer = [NSMutableData data];

    // create the connection with the request and start loading the data
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url];
    rssConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];

    // this creates a context for "push" parsing in which chunks of data that are not "well balanced" can be passed
    // to the context for streaming parsing. the handler structure defined above will be used for all the parsing. 
    // the second argument, self, will be passed as user data to each of the SAX handlers. the last three arguments
    // are left blank to avoid creating a tree in memory.
    context = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, self, NULL, 0, NULL);
    if (rssConnection != nil) {
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!done);
    }

    // release resources used only in this thread.
    xmlFreeParserCtxt(context);
    self.characterBuffer = nil;
    self.rssConnection = nil;
    self.currentGene = nil;
	self.geneSymbol = nil;
#ifdef PARSER_POOL
	[downloadAndParsePool release];
    self.downloadAndParsePool = nil;
#endif
}

// disable caching so that each time we run this app we are starting with a clean slate. You may not want to do this in your application.
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

// forward errors to the delegate.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    done = YES;
}

// called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // process the downloaded chunk of data.
    xmlParseChunk(context, (const char *)[data bytes], [data length], 0);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // signal the context that parsing is complete by passing "1" as the last parameter.
    xmlParseChunk(context, NULL, 0, 1);
    context = NULL;
    // set the condition which ends the run loop.
    done = YES; 
}

# pragma mark parsing support methods

- (void)finishedCurrentGene {
	[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(addToGeneList:) withObject:self.currentGene waitUntilDone:YES];
    self.currentGene = nil;
#ifdef PARSER_POOL
	[self releasePool];
#endif
}

// character data is appended to a buffer until the current element ends.
- (void)appendCharacters:(const char *)charactersFound length:(NSInteger)length {
    [characterBuffer appendBytes:charactersFound length:length];
}

- (NSString *)currentString {
	
	// create a string with the character data using UTF-8 encoding. UTF-8 is the default XML data encoding.
    NSString *currentString = [[[NSString alloc] initWithData:characterBuffer encoding:NSUTF8StringEncoding] autorelease];
    [characterBuffer setLength:0];
	
#ifdef PARSER_POOL
	// keep track of created string
	createdStringCount++;
#endif
	
	// outta here
    return currentString;
}

#ifdef PARSER_POOL
- (void) releasePool {
	[downloadAndParsePool release];
	self.downloadAndParsePool = [[NSAutoreleasePool alloc] init];
	createdStringCount = 0;
}
#endif

@end

#pragma mark SAX Parsing Callbacks

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, 
                            int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes) {
    EFetchReader *parser = (EFetchReader *)ctx;
	// The second parameter to strncmp is the name of the element, which we known from the XML schema of the feed.
    // The third parameter to strncmp is the number of characters in the element name, plus 1 for the null terminator.
    if (prefix == NULL && !strncmp((const char *)localname, kEntrezgene, kEntrezgene_length)) {
        Gene *newGene = [[Gene alloc] init];
        parser.currentGene = newGene;
        [newGene release];
        parser.parsingAGene = YES;
		parser.currentGene.symbol = parser.geneSymbol;
		parser.lookForRIFs = NO;
		parser.lookForMIM = NO;
		parser.lookForLocusLink = NO;
		parser.lookForPubMedID = NO;
    }
	else if (parser.parsingAGene && (prefix == NULL &&
			  ((!strncmp((const char *)localname, kSubsource_name, kSubsource_name_length)) ||
			   (!strncmp((const char *)localname, kGeneref_maploc, kGeneref_maploc_length))||
			   (!strncmp((const char *)localname, kOrgref_taxname, kOrgref_taxname_length)) ||
			   (!strncmp((const char *)localname, kGeneref_locus, kGeneref_locus_length)) ||
			   (!strncmp((const char *)localname, kGeneref_desc, kGeneref_desc_length)) ||
			   (!strncmp((const char *)localname, kEntrezgene_summary, kEntrezgene_summary_length)) ||
			   (!strncmp((const char *)localname, kGeneref_syn, kGeneref_syn_length)) ||
			   (!strncmp((const char *)localname, kProtref_name, kProtref_name_length)) ||
			   (!strncmp((const char *)localname, kGene_commentary_type, kGene_commentary_type_length)) ||
			   (!strncmp((const char *)localname, kDBTag, kDBTag_length)) ||
			   (!strncmp((const char *)localname, kGene_source_src, kGene_source_src_length)) ||
			   (parser.lookForRIFs && (!strncmp((const char *)localname, kGene_commentary_text, kGene_commentary_text_length))) ||
			   (parser.lookForPubMedID && (!strncmp((const char *)localname, kPubMed_id, kPubMed_id_length))) ||
			   (parser.lookForMIM && (!strncmp((const char *)localname, kObjectID, kObjectID_length))) ||
			   (parser.lookForLocusLink && (!strncmp((const char *)localname, kGene_source_int, kGene_source_int_length)))))) {
        parser.storingCharacters = YES;
		if (!strncmp((const char *)localname, kGene_commentary_type, kGene_commentary_type_length)) {
			unsigned int index = 0;
			NSString *value = nil;
			for (int indexAttribute = 0; indexAttribute < nb_attributes; ++indexAttribute, index +=5) {
				// per libxml docs, attributes: pointer to the array of (localname/prefix/URI/value/end) attribute values.
				const xmlChar *valueBegin = attributes[index+3];
				const xmlChar *valueEnd = attributes[index+4];
				value = [[NSString alloc] initWithBytes:valueBegin length:(valueEnd-valueBegin) encoding:NSUTF8StringEncoding];
				if (value != nil && [value isEqualToString:@"generif"]) {
					parser.lookForRIFs = YES;
					parser.lookForPubMedID = YES;
					parser.storingCharacters = NO;
					break;
				}
			}
			if (value != nil) {
				[value release];
			}
		}
    }
	
}

static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI) {    
    EFetchReader *parser = (EFetchReader *)ctx;
	if (parser.parsingAGene == NO) return;
	if (prefix == NULL) {
		if (!strncmp((const char *)localname, kEntrezgene, kEntrezgene_length)) {
			[parser finishedCurrentGene];
			parser.parsingAGene = NO;
		}
		else if (!strncmp((const char *)localname, kSubsource_name, kSubsource_name_length)) {
			parser.currentGene.chromosome = [parser currentString];
		}
		else if (!strncmp((const char *)localname, kGeneref_maploc, kGeneref_maploc_length)) {
			parser.currentGene.location = [parser currentString];
		}
		else if (!strncmp((const char *)localname, kOrgref_taxname, kOrgref_taxname_length)) {
			parser.currentGene.organism = [parser currentString];
		}
		else if (!strncmp((const char *)localname, kGeneref_locus, kGeneref_locus_length)) {
			parser.currentGene.symbol = [parser currentString];
		}
		else if (!strncmp((const char *)localname, kGeneref_desc, kGeneref_desc_length)) {
			parser.currentGene.description = [parser currentString];
		}
		else if (!strncmp((const char *)localname, kEntrezgene_summary, kEntrezgene_summary_length)) {
			parser.currentGene.summary = [parser currentString];
		}
		else if ((!strncmp((const char *)localname, kDBTag, kDBTag_length)) && ([[parser currentString] isEqualToString:@"MIM"])) {
			parser.lookForMIM = YES;
		}
		else if (parser.lookForMIM && ((!strncmp((const char *)localname, kObjectID, kObjectID_length)))) {
			parser.currentGene.mim = [parser currentString];
			parser.lookForMIM = NO;
		}
		else if ((!strncmp((const char *)localname, kGene_source_src, kGene_source_src_length)) && ([[parser currentString] isEqualToString:@"LocusLink"])) {
			parser.lookForLocusLink = YES;
		}
		else if (parser.lookForLocusLink && ((!strncmp((const char *)localname, kGene_source_int, kGene_source_int_length)))) {
			parser.currentGene.geneID = [parser currentString];
			parser.lookForLocusLink = NO;
		}
		else if (!strncmp((const char *)localname, kGeneref_syn, kGeneref_syn_length)) {
			parser.currentGene.aliases = (parser.currentGene.aliases == nil) ?
			[NSString stringWithFormat:@"%@<delimiter>", [parser currentString]] :
			[parser.currentGene.aliases stringByAppendingString:[NSString stringWithFormat:@"%@<delimiter>", [parser currentString]]];
		}
		else if (!strncmp((const char *)localname, kProtref_name, kProtref_name_length)) {
			parser.currentGene.designations = (parser.currentGene.designations == nil) ?
			[NSString stringWithFormat:@"%@<delimiter>", [parser currentString]] :
			[parser.currentGene.designations stringByAppendingString:[NSString stringWithFormat:@"%@<delimiter>", [parser currentString]]];
		}
		else if (parser.lookForRIFs && ((!strncmp((const char *)localname, kGene_commentary_text, kGene_commentary_text_length)))) {
			parser.currentGeneRIF = [[RIF alloc] init]; 
			parser.currentGeneRIF.rif = [parser currentString];
			parser.lookForRIFs = NO;
		}
		else if (parser.lookForPubMedID && ((!strncmp((const char *)localname, kPubMed_id, kPubMed_id_length)))) {
			parser.currentGeneRIF.pubmedID = [parser currentString];
			[parser.currentGene.rifList addObject:parser.currentGeneRIF];
			parser.lookForPubMedID = NO;
		}
	}
	parser.storingCharacters = NO;
	
#ifdef PARSER_POOL
	// periodically purge the autorelease pool. The frequency of this action may need to be tuned according to the 
    // size of the objects being parsed. The goal is to keep the autorelease pool from growing too large, but 
    // taking this action too frequently would be wasteful and reduce performance.
	if (parser.createdStringCount == kAutoreleasePoolPurgeFrequency) {
		[parser releasePool];
	}
#endif
}

static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len) {
    EFetchReader *parser = (EFetchReader *)ctx;
	
    // A state variable, "storingCharacters", is set when nodes of interest begin and end. 
    // This determines whether character data is handled or ignored. 
    if (parser.storingCharacters == NO) return;
    [parser appendCharacters:(const char *)ch length:len];
}

static void errorEncounteredSAX(void *ctx, const char *msg, ...) {
    NSCAssert(NO, @"Unhandled error encountered during SAX parse.");
}


