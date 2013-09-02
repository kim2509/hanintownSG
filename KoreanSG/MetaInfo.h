//
//  MetaInfo.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 25..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MetaInfo : NSObject {
    
    int seq;
    NSString *name;
    NSString *value;
    NSString *desc1;
    
}

@property(nonatomic) int seq;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *value;
@property(nonatomic, retain) NSString *desc;

@end
