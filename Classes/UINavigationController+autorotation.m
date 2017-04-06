//
//  UINavigationController+autorotation.m
//  biogene-client
//
//  Created by Benjamin Gross on 3/6/13.
//
//

#import "UINavigationController+autorotation.h"

@implementation UINavigationController (autorotation)

-(BOOL)shouldAutorotate
{
    
    //UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    //return YES;
    return [self.topViewController shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
