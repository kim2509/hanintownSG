//
//  KoreanShopListController.h
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 14..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"
#import <CoreLocation/CoreLocation.h>
#import "CategoryViewDelegate.h"

@interface KoreanShopListViewController : DYViewController <UITableViewDelegate, CategoryViewDelegate,UINavigationControllerDelegate,
UITableViewDataSource,UISearchBarDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, 
UIImagePickerControllerDelegate> {
    
    NSMutableArray *shopList;
    NSMutableArray *favoritesShopList;
    NSMutableArray *recentlyOpenedShopList;
    NSMutableArray *menuList;
    
    UIImageView* navTitleView;
    UIBarButtonItem *mapButton;
    UIButton *mapButtonCustom;
    
    UIToolbar *toolbar;
    UIBarButtonItem *categorySelectButton;
    UIBarButtonItem *viewOptionButton;
    UIBarButtonItem *sortOptionButton;
    
    UIImageView *viewOptionImageView;
    UIImageView *sortOptionImageView;
    
    UIButton *tabButton1;
    UIButton *tabButton2;
    UIButton *tabButton3;
    
    UITableView *myTableView;
    
    NSMutableArray *tableData;
    DataManager *dataManager;
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    UISearchBar* searchBar;
    
    NSIndexPath *selectedIndexPath;
    
    UISegmentedControl* viewOption;
    UISegmentedControl* sortOption;
    
    int selectedTabIndex;
    
    BOOL bNeverShowPrice;
    
    Shop *tempShop;
    Menu *tempMenu;
}

@property(nonatomic, retain) NSMutableArray *shopList, *favoritesShopList, *recentlyOpenedShopList, *menuList;
@property(nonatomic, retain) NSMutableArray *tableData;
@property(nonatomic, retain) UIBarButtonItem *mapButton;
@property(nonatomic,retain) UIToolbar *toolbar;
@property(nonatomic,retain) DataManager *dataManager;
@property(nonatomic,retain) UISearchBar* searchBar;
@property(nonatomic,retain) NSIndexPath* selectedIndexPath;
@property(nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property(nonatomic, retain) UIBarButtonItem *categorySelectButton, *viewOptionButton, *sortOptionButton;
@property(nonatomic,retain) UIImageView *viewOptionImageView, *sortOptionImageView;
@property(nonatomic,retain) Shop *tempShop;
@property(nonatomic,retain) Menu *tempMenu;

- (void) setTitle:(NSString *)title;
- (void) addNavigationBarButtons;
- (void) showMap;
- (void) initToolBarItems;
-(void)setToolbarBack:(NSString*)bgFilename toolbar:(UIToolbar*)bottombar;
- (void) categorySelect;
- (void) viewOptionChanged:(id) sender;
-(void) sortOptionChanged:(id) sender;

- (void) addTabButtons;
-(void) tabButton1Clicked:(id) sender;
-(void) tabButton2Clicked:(id) sender;
-(void) tabButton3Clicked:(id) sender;

-(void) updateShop:(NSNotification *) notification;

-(void) shopSelect:(Shop *) shop;
-(void) shopImageSelected:(Shop *) shop;
-(void) menuSelect:(Menu *) menu;
-(void) menuImageSelected:(Menu *) menu;

@end
