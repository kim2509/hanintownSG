//
//  MetaInfo.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 25..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MetaInfo.h"


@implementation MetaInfo

@synthesize seq, name, value, desc;

- (void)dealloc {
    
    [name release];
    [value release];
    [desc release];
    
    [super dealloc];
}


@end
