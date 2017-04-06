//
//  AppDelegate.h
//  biogene-client
//
//  Created by Benjamin on 2/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Gene;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    
@private
    UINavigationController *navigationController;
	NSMutableArray *geneList;
	NSString *count;
	NSString *retstart;
	Gene *currentGene;
}

@property (nonatomic, retain, readonly) UIWindow *window;
@property (nonatomic, retain) NSString *count;
@property (nonatomic, retain) NSString *retstart;

- (void)clearGeneList;
- (void)addToGeneList:(Gene *)newGene;
- (id)geneInListAtIndex:(NSUInteger)theIndex;
- (NSMutableArray *)getGeneList;
- (NSString *)getRetstart;
- (NSString *)getCount;
- (void)setGeneOfInterest:(Gene *)newGene;
- (Gene*)getGeneOfInterest;

@end

