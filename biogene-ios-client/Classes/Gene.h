#import <Foundation/Foundation.h>

@interface Gene : NSObject {

@private    
    NSString *symbol;
	NSString *tag;
    NSString *summary;
	NSString *organism;
	NSString *description;
	NSMutableArray *rifList;
	NSString *aliases;
	NSString *designations;
	NSString *chromosome;
	NSString *location;
	NSString *mim;
	NSString *geneID;
}

@property (nonatomic, retain) NSString *symbol;
@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *organism;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSMutableArray *rifList;
@property (nonatomic, retain) NSString *aliases;
@property (nonatomic, retain) NSString *designations;
@property (nonatomic, retain) NSString *chromosome;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *mim;
@property (nonatomic, retain) NSString *geneID;

@end
