//
//  MenuGroup.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 9. 16..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MenuGroup : NSObject {
    
    NSString *menuName;
    int count;
    NSString *menuType;
}

@property(nonatomic) int count;
@property(nonatomic, retain) NSString *menuName;
@property(nonatomic, retain) NSString *menuType;

@end
