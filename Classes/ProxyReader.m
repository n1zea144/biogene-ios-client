#import "ProxyReader.h"
#import "Gene.h"
#import "RIF.h"
#import "constants.h"
#import <UIKit/UIKit.h>

static NSString *kReturnCode = @"return_code";
static NSString *kGeneInfo = @"gene_info";
static NSString *kCount = @"count";

static NSString *kGeneID = @"gene_id";
static NSString *kGeneSymbol = @"gene_symbol";
static NSString *kGeneTag = @"gene_tag";
static NSString *kGeneOrganism = @"gene_organism";
static NSString *kGeneLocation = @"gene_location";
static NSString *kGeneChromosome = @"gene_chromosome";
static NSString *kGeneDescription = @"gene_description";
static NSString *kGeneAliases = @"gene_aliases";
static NSString *kGeneDesignations = @"gene_designations";
static NSString *kGeneSummary = @"gene_summary";
static NSString *kGeneMim = @"gene_mim";

static NSString *kGeneRIF = @"gene_rif";
static NSString *kRif = @"rif";
static NSString *kPubmedID = @"pubmed_id";

// class extension for private properties and methods
@interface ProxyReader ()

@property (nonatomic, retain) RIF *currentRIF;
@property (nonatomic, retain) Gene *currentGene;
@property (nonatomic, retain) NSMutableString *contentOfCurrentGeneProperty;
@property (nonatomic, retain) NSString *serverReturnCode;

@end

@implementation ProxyReader

@synthesize currentRIF;
@synthesize currentGene;
@synthesize serverReturnCode;
@synthesize contentOfCurrentGeneProperty;

- (void)dealloc {
	[self.currentRIF release];
	[self.currentGene release];
	[self.contentOfCurrentGeneProperty release];
	[self.serverReturnCode release];
    [super dealloc];
}

#pragma mark parser methods

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error serverReturnCode:(NSString **)code {
	
	// create parser with given url
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];

	// set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[parser setDelegate:self];

	// depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	
	// init string to hold current property value
	self.contentOfCurrentGeneProperty = [NSMutableString string];
	
	// init string to hold server return code
	self.serverReturnCode = [NSString string];

	// lets parse this bitch
	[parser parse];
	
	// set parse error
	NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
    }
	
	// set serverReturnCode
	if (code) {
		*code = self.serverReturnCode;
	}
	
	// outta here
	[parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

	if ([elementName isEqualToString:kGeneInfo]) {
		self.currentGene = [[Gene alloc] init];
	}
	else if ([elementName isEqualToString:kGeneRIF]) {
		self.currentRIF = [[RIF alloc] init];
	}
	else if ([elementName isEqualToString:kReturnCode] ||
 			 [elementName isEqualToString:kCount] ||
			 [elementName isEqualToString:kGeneID] ||
 			 [elementName isEqualToString:kGeneSymbol] ||
  			 [elementName isEqualToString:kGeneTag] ||
 			 [elementName isEqualToString:kGeneOrganism] ||
			 [elementName isEqualToString:kGeneLocation] ||
			 [elementName isEqualToString:kGeneChromosome] ||
			 [elementName isEqualToString:kGeneDescription] ||
			 [elementName isEqualToString:kGeneAliases] ||
			 [elementName isEqualToString:kGeneDesignations] ||
			 [elementName isEqualToString:kGeneSummary] ||
			 [elementName isEqualToString:kGeneMim] ||
			 [elementName isEqualToString:kRif] ||
			 [elementName isEqualToString:kPubmedID]) {
		[self.contentOfCurrentGeneProperty setString:@""];
		storingProperty = YES;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     

	if (storingProperty) {
		NSString *property = [self.contentOfCurrentGeneProperty stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
		if ([elementName isEqualToString:kReturnCode]) {
			self.serverReturnCode = property;
		}
		else if ([elementName isEqualToString:kCount]) {
			[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(setCount:) withObject:property waitUntilDone:NO];
		}
		else if ([elementName isEqualToString:kGeneID]) {
			self.currentGene.geneID = property;
		}
		else if ([elementName isEqualToString:kGeneSymbol]) {
			self.currentGene.symbol = property;
		}
		else if ([elementName isEqualToString:kGeneTag]) {
			self.currentGene.tag = property;
		}
		else if ([elementName isEqualToString:kGeneOrganism]) {
			self.currentGene.organism = property;
		}
		else if ([elementName isEqualToString:kGeneLocation]) {
			self.currentGene.location = property;
		}
		else if ([elementName isEqualToString:kGeneChromosome]) {
			self.currentGene.chromosome = property;
		}
		else if ([elementName isEqualToString:kGeneDescription]) {
			self.currentGene.description = property;
		}
		else if ([elementName isEqualToString:kGeneAliases]) {
			self.currentGene.aliases = [property stringByReplacingOccurrencesOfString:kDelimiter withString:kAliasesDesignationsDelimiter];
		}
		else if ([elementName isEqualToString:kGeneDesignations]) {
			self.currentGene.designations = [property stringByReplacingOccurrencesOfString:kDelimiter withString:kAliasesDesignationsDelimiter];
		}
		else if ([elementName isEqualToString:kGeneSummary]) {
			self.currentGene.summary = property;
		}
		else if ([elementName isEqualToString:kGeneMim]) {
			self.currentGene.mim = property;
		}
		else if ([elementName isEqualToString:kRif]) {
			self.currentRIF.rif = property;
		}
		else if ([elementName isEqualToString:kPubmedID]) {
			self.currentRIF.pubmedID = property;
		}
		storingProperty = NO;
	}
	else if ([elementName isEqualToString:kGeneInfo]) {
		// end gene info, store it
		[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(addToGeneList:) withObject:self.currentGene waitUntilDone:NO];
		[self.currentGene release];
	}
	else if ([elementName isEqualToString:kGeneRIF]) {
		[self.currentGene.rifList addObject:self.currentRIF];
		[self.currentRIF release];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (storingProperty) [self.contentOfCurrentGeneProperty appendString:string];
}

@end
