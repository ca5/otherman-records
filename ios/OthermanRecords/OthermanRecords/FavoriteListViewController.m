//
//  FavoriteListViewController.m
//  OthermanRecords
//
//  Created by ca54makske on 13/04/13.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "FavoriteListViewController.h"
#import "Favorite.h"

@interface FavoriteListViewController ()

@end

@implementation FavoriteListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Favorite list loaded");
    [(Favorite *)[Favorite instance] load];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return  [[Favorite instance] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoriteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
        
    UIImageView *thumbnail  = (UIImageView*)[cell viewWithTag:1];
    UILabel *title = (UILabel*)[cell viewWithTag:2];
    UILabel *creator = (UILabel*)[cell viewWithTag:3];
    
    NSDictionary *favorite = [[Favorite instance] objectAtIndex:indexPath.row];
    NSString *cutnum = [favorite objectForKey:@"cutnum"];
    NSNumber *tracknum = [favorite objectForKey:@"tracknum"];
    Jacket *jacket = [Jacket instanceWithDelegate:self];
    thumbnail.image = [jacket imageWithCutnum:cutnum];
    TrackList *tracklist = [TrackList instanceWithDelegate:self];
    NSDictionary *track = [tracklist trackWithCutnum:cutnum tracknum:tracknum];    
    title.text = [track objectForKey:@"title"];
    creator.text = [track objectForKey:@"creator"];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void) jacketDidFinishLoadingWithCutnum:(NSString *)cutnum
{
    //do nothing
}

-(void)jacketDidFailWithError:(NSError *)error
{
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]Load Jacket error:%@", error_str);
}

-(void)trackDidFinishLoading
{
    //[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.tableView reloadData];
    
}

-(void)trackDidFailWithError:(NSError *)error
{
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]Load Track error:%@", error_str);
}


@end
