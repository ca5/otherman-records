//
//  AlbumListViewController.m
//  OthermanRecords
//
//  Created by ca54makske on 13/02/24.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "AlbumListViewController.h"
#import "PlayerViewController.h"
#import "MultiRequestOperation.h"
#import "AlbumList.h"
#import "PlayList.h"
#import "MBProgressHUD.h"

@implementation AlbumListViewController
{
    NSString *_tracknum; //古いリリースで一部分数表記
    NSOperationQueue *_queue;
    NSMutableDictionary *_images;
}
@synthesize cutnum = _cutnum;

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
    self.hidesBottomBarWhenPushed = YES;

    [[TrackList instanceWithDelegate:self] load];    
    self.navigationController.navigationBar.tintColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    self.tableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0  ){
        cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95];
    }else if(indexPath.row % 2){
        cell.backgroundColor =  [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:0.95];
    }else{
        cell.backgroundColor =  [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.95];
    }    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 1) {
		return [[[TrackList instanceWithDelegate:self] listWithCutnum:_cutnum]  count];
	}else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    // Configure the cell...
    if(indexPath.section == 1){
        static NSString *CellIdentifier = @"TrackCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        UILabel *title  = (UILabel*)[cell viewWithTag:1];
        UILabel *creator = (UILabel*)[cell viewWithTag:2];
        UILabel *num = (UILabel*)[cell viewWithTag:3];
        
        title.text = [[[[TrackList instanceWithDelegate:self] listWithCutnum:_cutnum] objectAtIndex:indexPath.row] objectForKey:@"title"];
        title.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        title.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        creator.text = [[[[TrackList instanceWithDelegate:self] listWithCutnum:_cutnum] objectAtIndex:indexPath.row] objectForKey:@"creator"];
        creator.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
        creator.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        num.text = [[[[TrackList instanceWithDelegate:self] listWithCutnum:_cutnum] objectAtIndex:indexPath.row] objectForKey:@"num"];
        num.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
        num.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        
        return cell;
    }else{
        static NSString *CellIdentifier = @"AlbumCell";

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        UIImageView *thumbnail  = (UIImageView*)[cell viewWithTag:1];
        UILabel *cutnum = (UILabel*)[cell viewWithTag:2];
        UILabel *title = (UILabel*)[cell viewWithTag:3];
        UILabel *artists = (UILabel*)[cell viewWithTag:4];
        UITextView *description = (UITextView*)[cell viewWithTag:5];
        UILabel *date = (UILabel*)[cell viewWithTag:6];

        thumbnail.image = [[Jacket instanceWithDelegate:self] imageWithCutnum:_cutnum];
        NSDictionary *album = [[AlbumList instanceWithDelegate:nil] albumWithCutnum:_cutnum];
        cutnum.text = [album objectForKey:@"cutnum"];
        cutnum.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
        title.text = [album objectForKey:@"album"];
        title.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        artists.text = [album objectForKey:@"artists"];
        artists.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
        description.text = [album objectForKey:@"description"];
        description.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        description.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        date.text = [album objectForKey:@"date"];
        date.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
        
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        return 44;

    }else{
        return 140;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        _tracknum = [[[[TrackList instanceWithDelegate:self] listWithCutnum:_cutnum] objectAtIndex:indexPath.row] objectForKey:@"num"];

        [self performSegueWithIdentifier:@"Player" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepare Segure: %@", [segue identifier]);

    if ( [[segue identifier] isEqualToString:@"Player"] ) {
        PlayerViewController *nextViewController = [segue destinationViewController];
        nextViewController.cutnum = _cutnum;
        nextViewController.tracknum = _tracknum;
        [[PlayList instance] setFromTrackList];
    }
}

-(void)trackDidFinishLoading
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.tableView reloadData];

}

-(void)trackDidFailWithError:(NSError *)error
{
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]Load Track error:%@", error_str);
}

-(void)albumDidFailWithError:(NSError *)error
{
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]Load Album error:%@", error_str);
}

-(void)jacketDidFailWithError:(NSError *)error
{
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]Load Jacket error:%@", error_str);
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                        change:(NSDictionary*)change context:(void*)context
{
}

-(void) jacketDidFinishLoadingWithCutnum:(NSString *)cutnum
{
}


@end
