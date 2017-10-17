//
//  AppDelegate.m
//  biogene-client
//
//  Created by Benjamin on 2/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "AppDelegate.h"
#import "constants.h"
#import "ProxyUtil.h"

// class extension for private properties and methods
@interface AppDelegate ()

@property (nonatomic, retain) NSMutableArray *geneList;
@property (nonatomic, retain, readwrite) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) Gene *currentGene;

@end

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize geneList;
@synthesize count;
@synthesize retstart;
@synthesize currentGene;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")) {
		NSLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
	}
	
	// init some members
	self.geneList = [NSMutableArray array];
	self.retstart = [NSString stringWithFormat:kRetStartDefaultValue];
	self.count = [NSString stringWithFormat:@"0"];
    
    //self.window.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
	
	// Configure and show the window
    //[self.window addSubview:[self.navigationController view]];
    [self.window setRootViewController:self.navigationController];
	[self.window makeKeyAndVisible];
	
	// check reachability
	BOOL networkReachable = [ProxyUtil networkReachable];
	if (!networkReachable) {
		[ProxyUtil showAlertNetworkUnreachable];
	}
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"application received low memory warning");
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

- (void)dealloc {
	[self.currentGene release];
	[self.count release];
	[self.retstart release];
	[self.geneList release];
	[self.navigationController release];
	[self.window release];
	[super dealloc];
}

- (void)clearGeneList {
	[self.geneList removeAllObjects];
}

- (void)addToGeneList:(Gene *)newGene {
	[self.geneList addObject:newGene];
}

- (id)geneInListAtIndex:(NSUInteger)theIndex {
	return [self.geneList objectAtIndex:theIndex];
}

- (NSMutableArray *)getGeneList {
	return self.geneList;
}

- (NSString *)getRetstart {
	return self.retstart;
}

- (NSString *)getCount {
	return self.count;
}

- (void)setGeneOfInterest:(Gene *)newGene {
	self.currentGene = newGene;
}

- (Gene *)getGeneOfInterest {
	return self.currentGene;
}

@end
