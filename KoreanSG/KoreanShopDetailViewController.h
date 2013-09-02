//
//  KoreanShopDetailViewController.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 20..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Shop.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "common.h"

@interface KoreanShopDetailViewController : DYViewController <UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,
MKMapViewDelegate, CLLocationManagerDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate> {
    
    UIToolbar *toolbar;
    NSMutableDictionary *detailInfo;
    Shop *shop;
    UITableView *myTableView;
    MKMapView *mapView;
    
    int scrollToMenuIndex;
    
    CLLocationManager *locationManager;    
    CLLocationCoordinate2D currentLocation;
    
    UIButton *favoritesButton;
    
    BOOL bNeverShowPrice;
    
    Menu *tempMenu;
}

@property(nonatomic,retain) UIToolbar *toolbar;
@property(nonatomic,retain) NSMutableDictionary *detailInfo;
@property(nonatomic,retain) Shop *shop;
@property(nonatomic) int scrollToMenuIndex;
@property(nonatomic,retain) Menu *tempMenu;

- (void) back;
- ( void ) addHeaderInfoButtonsToCell:(UITableViewCell *) cell;
- (void) customizeBasicInfoCell:(UITableViewCell *) cell;

-(void) addToFavorites :(id) sender;

@end
