//
//  PlayerViewController.m
//  OthermanRecords
//
//  Created by ca54makske on 13/02/24.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "PlayerViewController.h"
#import "Player.h"

@implementation PlayerViewController
@synthesize cutnum;
@synthesize tracknum;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog (@"cutnum:%@ tracknum:%@", self.cutnum, self.tracknum);
    [[Player instance] startWithCutnum:cutnum tracknum:tracknum];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
