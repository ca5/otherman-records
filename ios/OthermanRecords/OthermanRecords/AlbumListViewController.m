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
#import "AlbumList.h";

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
    [[TrackList instanceWithDelegate:self] load];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"table num:%d", [[[TrackList instanceWithDelegate:self] listWithCutnum:_cutnum]  count]);
    return  [[[TrackList instanceWithDelegate:self] listWithCutnum:_cutnum]  count] + 1;
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
    if(indexPath.row > 0){
        cell.textLabel.text = [[[[TrackList instanceWithDelegate:self] listWithCutnum:_cutnum] objectAtIndex:indexPath.row - 1] objectForKey:@"title"];
    }else{
        UIImage *img = [_images objectForKey:_cutnum];
        if(img != nil){
            cell.imageView.image = [_images objectForKey:_cutnum];
        }else{
            //load jacket image
            NSURL *jacketurl = [[AlbumList instanceWithDelegate:nil] jacketURLWithCutnum:_cutnum];
            NSLog(@"thumburl: %@", jacketurl);
            MultiRequestOperation *mro = [[MultiRequestOperation alloc] initWithURL:jacketurl];
            if(_queue == nil){
                _queue = [[NSOperationQueue alloc] init];
            }

            [mro addObserver:self forKeyPath:@"isFinished"
                     options:NSKeyValueObservingOptionNew context:indexPath.row];
            [_queue addOperation:mro];
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath > 0){
        _tracknum = [[[[TrackList instanceWithDelegate:self] listWithCutnum:_cutnum] objectAtIndex:indexPath.row -1] objectForKey:@"num"];

        [self performSegueWithIdentifier:@"Player" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepare Segure: %@", [segue identifier]);

    if ( [[segue identifier] isEqualToString:@"Player"] ) {
        PlayerViewController *nextViewController = [segue destinationViewController];
        //ここで遷移先ビューのクラスの変数receiveStringに値を渡している
        nextViewController.cutnum = _cutnum;
        nextViewController.tracknum = _tracknum;
    }
}

-(void)trackDidFinishLoading
{
    [self.tableView reloadData];
}

-(void)didFailWithError:(NSError *)error
{
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]Load Track error:%@", error_str);
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                        change:(NSDictionary*)change context:(void*)context
{
    UITableView *tableView = (UITableView *)self.view;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIImage *img = [[UIImage alloc] initWithData:((MultiRequestOperation *)object).data];
    cell.imageView.image = img;
    NSDictionary *album = [[AlbumList instanceWithDelegate:nil] objectAtIndex:context];
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
