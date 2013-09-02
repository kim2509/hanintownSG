//
//  AddressAnnotation.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 21..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface AddressAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *mTitle;
    NSString *mSubTitle;
}

@property(nonatomic, retain) NSString *mTitle;
@property(nonatomic, retain) NSString *mSubTitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c;

@end
