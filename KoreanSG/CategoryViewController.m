//
//  CategoryViewController.m
//  KoreanSG
//
//  Created by Dae-yong Kim on 11. 9. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CategoryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "common.h"

@implementation CategoryViewController

@synthesize delegate, categoryList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [categoryList release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(20, 47, 280, 350)];
    mainView.backgroundColor = [UIColor whiteColor];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 280, 24)];
    backgroundView.backgroundColor = [UIColor colorWithHexString:@"#f8f8f8"];
    
    [mainView addSubview:backgroundView];
    [backgroundView release];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
    titleView.backgroundColor = [UIColor colorWithHexString:@"#f8f8f8"];
    titleView.layer.cornerRadius = 10.0;
    
    CGRect cellTitleRect = CGRectMake( 15,12, 250, 20 );
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:cellTitleRect];
    titleLabel.text = @"원하시는 업종을 선택해 주세요.";
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithHexString:@"#888888"];
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake( 240,6, 30, 30 )];
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [closeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [closeBtn setTitleColor:[UIColor colorWithHexString:@"#888888"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeWindow) forControlEvents:UIControlEventTouchUpInside];
    
    [titleView addSubview:closeBtn];
    
    
    [mainView addSubview:titleView];
    [titleView release];
    
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, 280, 296)];
	myTableView.delegate = self;
	myTableView.dataSource = self;
    [mainView addSubview:myTableView];
    mainView.layer.cornerRadius = 10.0;
	[self.view addSubview:mainView];
    [mainView release];
    
    self.categoryList = [[DataManager sharedDataManager] categoryListWithCounts];    
}

-(void) closeWindow
{
    NSLog(@"closed..");
    [self.view removeFromSuperview];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return [categoryList count];
}

-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    return 38;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
     
        if ( [CellIdentifier isEqualToString:@"Cell"] )
        {
            CGRect cellTitleRect = CGRectMake( 20,12, 200, 20 );
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:cellTitleRect];
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.tag = 1;
            [cell.contentView insertSubview:titleLabel atIndex:0];
            [titleLabel release];
            
            CGRect categoryCountLabelRect = CGRectMake( 220,12, 50, 20 );
            UILabel *categoryCountLabel = [[UILabel alloc] initWithFrame:categoryCountLabelRect];
            categoryCountLabel.font = [UIFont systemFontOfSize:14];
            categoryCountLabel.backgroundColor = [UIColor clearColor];
            categoryCountLabel.textColor = [UIColor colorWithHexString:@"#305eb0"];
            categoryCountLabel.tag = 2;
            [cell.contentView addSubview:categoryCountLabel];
            [categoryCountLabel release];
            
            UIView *bgColorView = [[UIView alloc] init];
            [bgColorView setBackgroundColor:[UIColor colorWithHexString:@"#3a4764"]];
            [cell setSelectedBackgroundView:bgColorView];
            [bgColorView release];
        }
    }
	
    if ( [CellIdentifier isEqualToString:@"Cell"] )
	{
        UILabel *titleLabel = (UILabel *) [cell.contentView viewWithTag:1];
        UILabel *categoryCountLabel = (UILabel *) [cell.contentView viewWithTag:2];
        
        CGRect cellTitleRect = CGRectMake( 20,12, 250, 20 );
        titleLabel.frame = cellTitleRect;
        
        NSString *categoryString = [categoryList objectAtIndex:indexPath.row];
        titleLabel.text = [[categoryString componentsSeparatedByString:@"|"] objectAtIndex:0];
        categoryCountLabel.text = [NSString stringWithFormat:@"(%d)", 
                                   [[[categoryString componentsSeparatedByString:@"|"] objectAtIndex:1] intValue]];
        
        CGSize labelSize = [titleLabel.text sizeWithFont:titleLabel.font 
                                           constrainedToSize:titleLabel.frame.size 
                                               lineBreakMode:UILineBreakModeWordWrap];
        
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x,
                                          titleLabel.frame.origin.y, 
                                          labelSize.width, 
                                          labelSize.height );
        
        categoryCountLabel.frame = CGRectMake(titleLabel.frame.origin.x + titleLabel.frame.size.width + 10 ,
                                      titleLabel.frame.origin.y - 1, 
                                      50, 20);
	}
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
    //	NSUInteger fromRow = [fromIndexPath row];
    //    NSUInteger toRow = [toIndexPath row];
    
    
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    if ( [delegate respondsToSelector:@selector(didSelectCategory:)] )
    {
        NSString *category = @"";
        category = [categoryList objectAtIndex:[indexPath row]];
        [delegate didSelectCategory:[[category componentsSeparatedByString:@"|"] objectAtIndex:0]];
    }
    
    [self.view removeFromSuperview];
}
@end
