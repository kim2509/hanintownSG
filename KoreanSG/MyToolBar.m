//
//  MyToolBar.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 9. 25..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyToolBar.h"


#import "MyToolbar.h"

@implementation MyToolbar

- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed: @"bottom_bg.png"];
    [image drawInRect:CGRectMake(0, 0, 320, 51)];
}

@end
