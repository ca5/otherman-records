//
//  ReleaseListViewController.m
//  OthermanRecords
//
//  Created by ca54makske on 13/02/25.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "ReleaseListViewController.h"
#import "AlbumListViewController.h"

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
    [[AlbumList instanceWithDelegate:self] load];
    
    self.navigationController.navigationBar.tintColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default@2x.png"]];
    background.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = background;
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *album = [[AlbumList instanceWithDelegate:self] objectAtIndex:indexPath.row];
    cell.textLabel.text = [album objectForKey:@"album"];
    UIImage *img = [_images objectForKey:[album objectForKey:@"cutnum"]];
    if(img != nil){
        cell.imageView.image = [_images objectForKey:[album objectForKey:@"cutnum"]];
    }else{
        //load thumbnail image
        NSURL *thumburl = [[AlbumList instanceWithDelegate:self] jacketURLWithCutnum:[album objectForKey:@"cutnum"]];
        NSLog(@"thumburl: %@", thumburl);
        MultiRequestOperation *mro = [[MultiRequestOperation alloc] initWithURL:thumburl];
        if(_queue == nil){
            _queue = [[NSOperationQueue alloc] init];
        }

        [mro addObserver:self forKeyPath:@"isFinished"
                  options:NSKeyValueObservingOptionNew context:indexPath.row];
        [_queue addOperation:mro];
    }
    
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
    cell.textLabel.textColor =  [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    cell.textLabel.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

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
    [self.tableView reloadData];
}

-(void)didFailWithError:(NSError *)error
{
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]Load Album error:%@", error_str);
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                        change:(NSDictionary*)change context:(void*)context
{
    UITableView *tableView = (UITableView *)self.view;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(NSInteger)context inSection:0]];
    UIImage *img = [[UIImage alloc] initWithData:((MultiRequestOperation *)object).data];
    cell.imageView.image = img;
    NSDictionary *album = [[AlbumList instanceWithDelegate:self] objectAtIndex:context];
    if(img != nil){
        [_images setObject:img forKey:[album objectForKey:@"cutnum"]];
    }

    //cell.textLabel.text = @"loaded";
    [cell setNeedsLayout];
    
    
    // データの長さを取得する
    unsigned int    length;
    length = [((MultiRequestOperation *)object).data length];
    NSLog(@"data length %d id:%d", length, (int)context);
    
    // キー値監視を解除する
    [object removeObserver:self forKeyPath:keyPath];
}

@end
