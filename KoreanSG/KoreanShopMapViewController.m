//
//  KoreanShopMapViewController.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 8. 21..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KoreanShopMapViewController.h"
#import "AddressAnnotation.h"
#import "Shop.h"
#import "KoreanShopDetailViewController.h"
#import "common.h"
#import "MyToolBar.h"
#import "MetaInfo.h"
#import "CategoryViewController.h"

@implementation KoreanShopMapViewController

@synthesize toolbar, shopList, favoritesShopList, categoryViewController, viewOptionImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    	    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 372)];
    
    if ( [DYViewController isRetinaDisplay] )
    {
        mapView.frame = CGRectMake(mapView.frame.origin.x, mapView.frame.origin.y,
                                       mapView.frame.size.width, mapView.frame.size.height + 90 );
    }
    
    mapView.delegate = self;
    
    [self setTitle:@"지도 뷰"];

    [self.view insertSubview:mapView atIndex:0];
    
    [mapView.userLocation addObserver:self 
                                forKeyPath:@"location" 
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
                                   context:nil];
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_bg01.png"];
    UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButtonCustom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    backButtonCustom.frame = CGRectMake(0.0, 0.0, 63, 32);
    [backButtonCustom addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* titleLabel2 = [[[UILabel alloc] 
                             initWithFrame:CGRectMake(5, 0, 63, 32 )] autorelease];
    titleLabel2.text = @"Back";
    titleLabel2.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12.0];
    titleLabel2.textColor = [UIColor colorWithHexString:@"#4c4c4c"];
    titleLabel2.backgroundColor = [UIColor clearColor];
    titleLabel2.textAlignment = UITextAlignmentCenter;
    
    [backButtonCustom addSubview:titleLabel2];
	
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonCustom];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];
}

- (void)setTitle:(NSString *)title
{    
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.textColor = [UIColor colorWithHexString:@"#141414"];
        
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{    
    if ( bMoveToUserLocation ) {
        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;  
        
        /*
        MKCoordinateSpan span = mapView.region.span; 
        
        if ( span.latitudeDelta == 0 && span.longitudeDelta == 0 )
        {
            span.latitudeDelta  = 0.5; // Change these values to change the zoom
            span.longitudeDelta = 0.5; 
            region.span = span;
        }
         */
        
        [mapView setRegion:region animated:YES];   
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initToolBarItems];
    
    MetaInfo *metaInfo = [[DataManager sharedDataManager] getMetaInfo:@"SELECTED_VIEWOPTION_INDEX"];
    
    if ( metaInfo != nil && metaInfo.value != nil && [metaInfo.value isEqualToString:@""] == NO )
    {
        viewOption.selectedSegmentIndex = [[metaInfo value] intValue];
        
        if ( viewOption.selectedSegmentIndex == 0)
        {
            self.viewOptionImageView.image = [UIImage imageNamed:@"B1_on.png"];
        }
        else
        {
            self.viewOptionImageView.image = [UIImage imageNamed:@"B1_on2.png"];
        }
    }
    
    if ( [[mapView annotations] count] > 1 )
    {
        return;
    }
    
    [self loadShops];
}

-(void) loadShops
{
    /*Region and Zoom*/
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.214;
    span.longitudeDelta=0.219;

    for (id annotation in mapView.annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]]){
            [mapView removeAnnotation:annotation];
        }
    }
    
    if ( [shopList count] == 0 ) return;
    

    for (Shop *shop in self.shopList) 
    {   
        if ( [shop address] == nil || [[shop address] isEqualToString:@""] )
        {
            shop.longitude = kLocationEmpty;
            shop.latitude = kLocationEmpty;
            continue;   
        }

        CLLocationCoordinate2D location;
                
        if ( [shop longitude] == 0 || [shop latitude] == 0) {
            location = [self addressLocation:[shop address]];
            
            if ( location.longitude == 0 )
                shop.longitude = kLocationEmpty;
            else
                shop.longitude = location.longitude;
            
            if ( location.longitude == 0 )
                shop.latitude = kLocationEmpty;
            else
                shop.latitude = location.latitude;            
        }
        else if ( [shop longitude] == kLocationEmpty || [shop latitude] == kLocationEmpty )
            continue;
        else
        {
            location.longitude = [shop longitude];
            location.latitude = [shop latitude];
        }                
        region.span=span;
        region.center=location;
        
        AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
        addAnnotation.mTitle = [shop shopName];
        addAnnotation.mSubTitle = [shop address];
        [mapView addAnnotation:addAnnotation];
        [addAnnotation release];
    }

    region.center.longitude = 103.825819;
    region.center.latitude = 1.329413;
    
    [mapView setRegion:region animated:YES];
    [mapView regionThatFits:region];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.toolbar removeFromSuperview];
}

-(CLLocationCoordinate2D) addressLocation:(NSString *) address
{
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
                           [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] 
                                                        encoding:NSUTF8StringEncoding error:nil];
    NSArray *listItems = [locationString componentsSeparatedByString:@","];
    
    double latitude = 0.0;
    double longitude = 0.0;
    
    if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
        latitude = [[listItems objectAtIndex:2] doubleValue];
        longitude = [[listItems objectAtIndex:3] doubleValue];
    }
    else {
        //Show error
    }
    
    NSLog(@"latitude:%f longitude:%f", latitude, longitude);
    
    CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
    
    return location;
}

- (void) initToolBarItems
{
    MyToolbar *tBar = [[MyToolbar alloc] init];
    self.toolbar = tBar;
	[tBar release];
	self.toolbar.barStyle = UIBarStyleDefault;
    
    //Set the toolbar to fit the width of the app.
	[toolbar sizeToFit];
    
    //Caclulate the height of the toolbar
	CGFloat toolbarHeight = [toolbar frame].size.height;
	
	//Get the bounds of the parent view
	CGRect rootViewBounds = self.parentViewController.view.bounds;
	
	//Get the height of the parent view.
	CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
	
	//Get the width of the parent view,
	CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
	
	//Create a rectangle for the toolbar
	CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight );
	
	//Reposition and resize the receiver
	[toolbar setFrame:rectArea];
    
    locationOption = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 31, 29)];
    [locationOption setBackgroundImage:[UIImage imageNamed:@"icon_01.png"] forState:UIControlStateNormal];
    [locationOption setBackgroundImage:[UIImage imageNamed:@"icon_02.png"] forState:UIControlStateSelected];
    [locationOption addTarget:self action:@selector(locationOptionChanged:) forControlEvents:UIControlEventTouchUpInside];
    [locationOption setShowsTouchWhenHighlighted:YES];

    UIBarButtonItem *viewOptionBarButton = [[UIBarButtonItem alloc] initWithCustomView:locationOption];
    
    NSArray *viewOptionItems = [NSArray arrayWithObjects:@"전체",@"즐겨찾기",nil];
    
    viewOption = [[UISegmentedControl alloc] initWithItems:viewOptionItems];
    CGRect viewOptionRect = CGRectMake(0, 0, 130, 35);
    [viewOption setFrame:viewOptionRect];
    viewOption.segmentedControlStyle = UISegmentedControlStyleBar;
    viewOption.selectedSegmentIndex = 0;
    [viewOption addTarget:self
                   action:@selector(viewOptionChanged:)
         forControlEvents:UIControlEventValueChanged];
    
    viewOption.alpha = 0.1;
    UIView *viewOptionView = [[UIView alloc] initWithFrame:viewOptionRect];
    
    UIImageView *vImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"B1_on.png"]];
    self.viewOptionImageView = vImageView;
//    [vImageView release];
    viewOptionImageView.frame = viewOptionRect;
    
    [viewOptionView addSubview:viewOption];
    [viewOptionView addSubview:viewOptionImageView];
    [viewOptionImageView release];
    
    viewOptionButton = [[UIBarButtonItem alloc] init];
    [viewOptionButton setCustomView:viewOptionView];
    [viewOptionView release];
    
    UIButton *categoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    categoryButton.frame = CGRectMake(0, 0, 60, 35);
    [categoryButton setImage:[UIImage imageNamed:@"btn_01_off"] forState:UIControlStateNormal];
    [categoryButton setImage:[UIImage imageNamed:@"btn_01_on"] forState:UIControlStateSelected];
    [categoryButton setImage:[UIImage imageNamed:@"btn_01_on"] forState:UIControlStateHighlighted];
    [categoryButton addTarget:self action:@selector(categorySelect) forControlEvents:UIControlEventTouchUpInside];
    
    categorySelectButton = [[UIBarButtonItem alloc] init];
    [categorySelectButton setCustomView:categoryButton];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] 
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolbar setItems:[NSArray arrayWithObjects:viewOptionBarButton, flexibleSpace,
                       viewOptionButton, flexibleSpace, categorySelectButton, nil] animated:YES];
    [categorySelectButton release];
    [viewOptionBarButton release];
    [flexibleSpace release];
    
    //Add the toolbar as a subview to the navigation controller.
	[self.navigationController.view addSubview:toolbar];
}

- (void) locationOptionChanged:(id) sender
{
    if ( locationOption.selected == NO )
    {
        mapView.showsUserLocation=YES;
        //[mapView setTransform:CGAffineTransformMakeRotation(-1 * 3.14159 / 180)];
        bMoveToUserLocation = YES;
        locationOption.selected = YES;
    }
    else
    {
        mapView.showsUserLocation=NO;
        //[mapView setTransform:CGAffineTransformMakeRotation(-1 * 3.14159 / 180)];
        bMoveToUserLocation = YES;
        locationOption.selected = NO;
    }
}

- (void) viewOptionChanged:(id) sender
{
    if ( viewOption.selectedSegmentIndex == 0 )
    {
        self.viewOptionImageView.image = [UIImage imageNamed:@"B1_on.png"];
        
        DataManager *dataManager = [DataManager sharedDataManager];
        MetaInfo *metaInfo = [dataManager getMetaInfo:@"MAPVIEW_LAST_SELECTED_CATEGORY"];
        
        self.shopList = [dataManager shopListWithCategory:metaInfo.value];
    }
    else
    {
        self.viewOptionImageView.image = [UIImage imageNamed:@"B1_on2.png"];
        self.shopList = [[DataManager sharedDataManager] favoriteShopList];
    }
    
    MetaInfo *metaInfo = [[MetaInfo alloc] init];
    metaInfo.name = @"SELECTED_VIEWOPTION_INDEX";
    metaInfo.value = [NSString stringWithFormat:@"%d", viewOption.selectedSegmentIndex];
    [[DataManager sharedDataManager] insertMetaInfo:metaInfo];
    [metaInfo release];
    
    [self loadShops];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView2 viewForAnnotation:(id <MKAnnotation>) annotation{
    
    int selectedIndex = -1;
    
    for ( int i = 0; i < [shopList count]; i++ ) {
        
        Shop *shop = [shopList objectAtIndex:i];
        
        if ([[shop shopName] isEqualToString:[annotation title]] &&
            [[shop address] isEqualToString:[annotation subtitle]]) {
            selectedIndex = i;
            break;
        }
    }
    
    if ( selectedIndex == -1 )
    {
        //return [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    }
    
    if (annotation == mapView2.userLocation)
    {
        return nil;
    }
    
    UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	myDetailButton.frame = CGRectMake(0, 0, 23, 23);
	myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    myDetailButton.tag = selectedIndex;
    
	[myDetailButton addTarget:self action:@selector(shopSelected:) forControlEvents:UIControlEventTouchUpInside];
    
	MKPinAnnotationView *annView=[[[MKPinAnnotationView alloc] 
                                  initWithAnnotation:annotation reuseIdentifier:@"currentloc"] autorelease];
	annView.pinColor = MKPinAnnotationColorGreen;
    annView.animatesDrop=NO;
    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(-5, 5);
    annView.rightCalloutAccessoryView = myDetailButton;
    return annView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    bMoveToUserLocation = NO;
}


- (void)mapView:(MKMapView *)mapView1 didSelectAnnotationView:(MKAnnotationView *)mapView2
{
    // Set up the Left callout
}

- (void) shopSelected:(id) sender
{
    int selectedIndex = ((UIButton *) sender).tag;
    KoreanShopDetailViewController *detailViewController = 
    [[KoreanShopDetailViewController alloc] init];
    detailViewController.title = [[shopList objectAtIndex:selectedIndex] shopName];
    detailViewController.shop = [shopList objectAtIndex:selectedIndex];
	[self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}


- (void) categorySelect
{
    @try {
        
        self.categoryViewController = [[CategoryViewController alloc] init];
        categoryViewController.view.frame = [[UIScreen mainScreen] bounds];
        categoryViewController.view.opaque = NO;
        categoryViewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        categoryViewController.delegate = self;
        
        [self.navigationController.view addSubview:categoryViewController.view];
        [categoryViewController release];
	}
    @catch (NSException* ex) {
		NSLog(@"categorySelect failed: %@",ex);
	}
}

#pragma mark CategoryViewDelegate methods

-(void) didSelectCategory:(NSString *)category
{
    MetaInfo *metaInfo = [[MetaInfo alloc] init];
    metaInfo.name = @"MAPVIEW_LAST_SELECTED_CATEGORY";
    metaInfo.value = category;
    DataManager *dataManager = [DataManager sharedDataManager];
    [dataManager insertMetaInfo:metaInfo];
    
    viewOption.selectedSegmentIndex = 0;
    [self viewOptionChanged:nil];
    
    self.shopList = [dataManager shopListWithCategory:metaInfo.value];
    
    [metaInfo release];
    
    [self loadShops];
}

-(void) viewDidUnload
{
    
}

- (void)dealloc {
    
    [mapView.userLocation removeObserver:self forKeyPath:@"location"];
    [mapView removeFromSuperview]; // release crashes app
    [mapView release];
    [toolbar release];
    [shopList release];
    [favoritesShopList release];
    [geoCoder release];
    [mPlacemark release];
    [locationOption release];
    [viewOptionButton release];
    [viewOption release];
    [categoryViewController release];
    
    [viewOptionImageView release];
    
    [super dealloc];
}

@end
