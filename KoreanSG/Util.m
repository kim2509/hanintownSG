//
//  Util.m
//  KoreanSG
//
//  Created by Daeyong Kim on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

@implementation Util

+(CGSize) heightForCellWithText:(NSString *)comment size:(CGSize) size font:(UIFont *) font
{
    UILabel *commentLabel = [[UILabel alloc] init];
    commentLabel.numberOfLines = 0;
    CGRect cellUserRect = CGRectMake( 0, 0 , size.width, size.height );
    commentLabel.frame = cellUserRect;
    commentLabel.text = comment;
    
    CGSize resultSize = [commentLabel.text sizeWithFont:font 
                                      constrainedToSize:size 
                                          lineBreakMode:UILineBreakModeWordWrap];
    
    [commentLabel release];
    
    return resultSize;
}

@end
