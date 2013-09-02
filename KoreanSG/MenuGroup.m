//
//  MenuGroup.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 9. 16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuGroup.h"


@implementation MenuGroup

@synthesize count,menuName, menuType;

- (void)dealloc {
    [menuName release];
    [menuType release];
    
    [super dealloc];
}
@end
