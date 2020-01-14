//
//  SyncingViewController.m
//  grsyncx
//
//  Created by Michal Zelinka on 14/01/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "SyncingViewController.h"

@interface SyncingViewController ()

@end

@implementation SyncingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear
{
	[super viewWillAppear];

	NSWindow *window = self.view.window;
	window.title = NSLocalizedString(@"Synchronisation", @"Window title");
	window.minSize = self.view.bounds.size;
}

- (IBAction)closeButtonAction:(__unused id)sender
{
	[self dismissViewController:self];
}

@end
