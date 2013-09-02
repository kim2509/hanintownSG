//
//  UILabelUnderline.m
//  KoreanSG
//
//  Created by Daeyong Kim on 18/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UILabelUnderline.h"
#import "common.h"

@implementation UILabelUnderline

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx, 59.0f/255.0f, 89.0f/255.0f, 153.0f/255.0f, 1.0f); // RGBA
    CGContextSetLineWidth(ctx, 1.0f);
    
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height - 1);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, self.bounds.size.height - 1);
    
    CGContextStrokePath(ctx);
    
    [super drawRect:rect];  
}


@end
