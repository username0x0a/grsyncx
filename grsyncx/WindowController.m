//
//  WindowController.m
//  grsyncx
//
//  Created by Michal Zelinka on 13/01/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "WindowController.h"

@interface WindowController () <NSToolbarDelegate>

@property (nonatomic, weak) IBOutlet id<WindowActionsResponder> actionsResponder;

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

	_actionsResponder = (id)self.contentViewController;
}

- (IBAction)simulateButton:(id)sender
{
	[_actionsResponder didReceiveSimulateAction];
}

- (IBAction)executeButton:(id)sender
{
	[_actionsResponder didReceiveExecuteAction];
}

@end
