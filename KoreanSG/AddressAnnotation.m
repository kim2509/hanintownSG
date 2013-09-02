//
//  AddressAnnotation.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 21..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddressAnnotation.h"


@implementation AddressAnnotation

@synthesize coordinate, mTitle, mSubTitle;

- (NSString *)subtitle{
    return mSubTitle;
}

- (NSString *)title{
    return mTitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c
{
    coordinate=c;
    return self;
}

- (void)dealloc {
    [mTitle release];
    [mSubTitle release];
    
    [super dealloc];
}

@end
