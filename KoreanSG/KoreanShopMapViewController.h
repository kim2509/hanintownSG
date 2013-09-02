//
//  KoreanShopMapViewController.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 21..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "common.h"
#import "CategoryViewDelegate.h"

@class CategoryViewController;
@interface KoreanShopMapViewController : UIViewController <MKMapViewDelegate,CategoryViewDelegate>
{
    MKMapView *mapView;
    UIToolbar *toolbar;
    MKReverseGeocoder *geoCoder;
	MKPlacemark *mPlacemark;
    NSMutableArray *shopList;
    NSMutableArray *favoritesShopList;
    
    BOOL bMoveToUserLocation;
    UIButton *locationOption;
    
    UIBarButtonItem *viewOptionButton;
    UISegmentedControl* viewOption;
    
    UIBarButtonItem *categorySelectButton;
    CategoryViewController *categoryViewController;
    
    UIImageView *viewOptionImageView;
}

@property(nonatomic,retain) UIToolbar *toolbar;
@property(nonatomic,retain) NSMutableArray *shopList, *favoritesShopList;
@property(nonatomic,retain) CategoryViewController *categoryViewController;
@property(nonatomic,retain) UIImageView *viewOptionImageView;

-(CLLocationCoordinate2D) addressLocation:(NSString *) address;

- (void) initToolBarItems;
-(void) loadShops;

- (void) viewOptionChanged:(id) sender;
- (void) shopSelected:(id) sender;

@end
