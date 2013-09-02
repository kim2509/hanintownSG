//
//  CategoryViewDelegate.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 9. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CategoryViewDelegate <NSObject>

-(void) didSelectCategory:(NSString *) category;

@end
