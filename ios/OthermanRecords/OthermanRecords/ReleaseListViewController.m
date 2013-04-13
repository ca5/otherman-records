//
//  ReleaseListViewController.m
//  OthermanRecords
//
//  Created by ca54makske on 13/02/25.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "ReleaseListViewController.h"
#import "AlbumListViewController.h"
#import "MBProgressHUD.h"

@implementation ReleaseListViewController
{
    NSString *_cutnum;
    NSMutableData *_thumbdata;
    NSOperationQueue *_queue;
    NSMutableDictionary *_images;

}

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
    _images = [NSMutableDictionary dictionary];
    [[AlbumList instanceWithDelegate:self] loadWithCache:NO];
    
    self.navigationController.navigationBar.tintColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default@2x.png"]];
    background.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = background;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return  [[AlbumList instanceWithDelegate:self] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    static NSString *CellIdentifier = @"ReleaseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *album = [[AlbumList instanceWithDelegate:self] objectAtIndex:indexPath.row];
    UILabel *title = (UILabel*)[cell viewWithTag:1];
    UILabel *artists = (UILabel*)[cell viewWithTag:2];
    UIImageView *thumbnail  = (UIImageView*)[cell viewWithTag:3];
    UILabel *cutnum = (UILabel*)[cell viewWithTag:4];

    
    title.text = [album objectForKey:@"album"];
    title.textColor =  [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    title.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    artists.text = [album objectForKey:@"artists"];
    artists.textColor =  [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    artists.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    thumbnail.image = [[Jacket instanceWithDelegate:self] imageWithCutnum:[album objectForKey:@"cutnum"]];
    cutnum.text = [NSString stringWithFormat:@"[%@]",[album objectForKey:@"cutnum"]];
    cutnum.textColor =  [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    cutnum.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2){
        cell.backgroundColor =  [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:0.95];
    }else{
        cell.backgroundColor =  [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.95];
    }



}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _cutnum = [[[AlbumList instanceWithDelegate:self] objectAtIndex:indexPath.row] objectForKey:@"cutnum"];
    [self performSegueWithIdentifier:@"Album" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepare Segure: %@", [segue identifier]);
    
    if ( [[segue identifier] isEqualToString:@"Album"] ) {
        AlbumListViewController *nextViewController = [segue destinationViewController];
        nextViewController.cutnum = _cutnum;
    }
}

-(void)albumDidFinishLoading
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [[Jacket instanceWithDelegate:self] load];
    [self.tableView reloadData];
}

-(void)didFailWithError:(NSError *)error
{
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]Load Album error:%@", error_str);
}

-(void) jacketDidFinishLoadingWithCutnum:(NSString *)cutnum
{
    int i = 0;
    for(; i < [[AlbumList instanceWithDelegate:self] count]; i++ ){
        if(cutnum == [[[AlbumList instanceWithDelegate:self] objectAtIndex:i] objectForKey:@"cutnum"]){
            break;
        }
    }
    UITableView *tableView = (UITableView *)self.view;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(NSInteger)i inSection:0]];    
    UIImageView *thumbnail  = (UIImageView*)[cell viewWithTag:3];
    thumbnail.image = [[Jacket instanceWithDelegate:self] imageWithCutnum:cutnum];
    [cell setNeedsLayout];

}


@end
