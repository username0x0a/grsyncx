//
//  WindowController.m
//  grsyncx
//
//  Created by Michal Zelinka on 13/01/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "WindowController.h"
#import "WindowActionsResponder.h"
#import "UNXParsable.h"


@interface WindowController () <NSToolbarDelegate>

@property (nonatomic, weak) IBOutlet NSSegmentedControl *addDeleteButton;

@property (nonatomic, weak) id<WindowActionsResponder> actionsResponder;

@end


@implementation WindowController

- (void)windowDidLoad
{
	[super windowDidLoad];

	NSViewController *vc = self.contentViewController;

	if ([vc conformsToProtocol:@protocol(WindowActionsResponder)])
		_actionsResponder = (id)vc;
	else @throw @"Invalid Window actions responder";
}

// Note: `__unused` flag may cause these selectors not being visible
//       to Interface Builder. Add it later after making a connection
//       in the Interface Builder UI.

- (IBAction)simulateButton:(__unused id)sender
{
	const id<WindowActionsResponder> resp = _actionsResponder;
	[resp didReceiveSimulateAction];
}

- (IBAction)executeButton:(__unused id)sender
{
	const id<WindowActionsResponder> resp = _actionsResponder;
	[resp didReceiveExecuteAction];
}

- (IBAction)addDeleteButton:(__unused id)sender
{
	NSInteger tag = _addDeleteButton.selectedTag;

	if (tag == 1) NSLog(@"Add");
	if (tag == 2) NSLog(@"Delete");
}

@end
