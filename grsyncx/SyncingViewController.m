//
//  SyncingViewController.m
//  grsyncx
//
//  Created by Michal Zelinka on 14/01/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "SyncingViewController.h"

@implementation SyncingOptions

@end

@interface SyncingViewController ()

@property (nonatomic, weak) IBOutlet NSTextView *outputTextView;

@end

@implementation SyncingViewController

- (void)setSyncingOptions:(SyncingOptions *)syncingOptions
{
	_syncingOptions = syncingOptions;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	if (@available(macOS 10.15, *)) {
		_outputTextView.font =
			[NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular];
	}
}

- (void)viewWillAppear
{
	[super viewWillAppear];

	NSWindow *window = self.view.window;
	window.title = NSLocalizedString(@"Synchronisation", @"Window title");
	window.minSize = self.view.bounds.size;
}

- (void)viewDidAppear
{
	[self executeRsync];
}


- (void)executeRsync
{

	SyncingOptions *options = _syncingOptions;

	NSAssert(options != nil, @"Options missing");

	NSMutableArray<NSString *> *args = [options.arguments mutableCopy];
	if (options.sourcePath) [args addObject:options.sourcePath];
	if (options.destinationPath) [args addObject:options.destinationPath];

	NSTask *task = [NSTask new];
	task.launchPath = @"/usr/bin/rsync";
	task.arguments = args;

	NSPipe *pipe = [NSPipe new];
	task.standardOutput = pipe;
	task.standardError = pipe;

/// Asynchronous
	static id observer = nil;
	NSFileHandle *handle = pipe.fileHandleForReading;
	NSTextView *outputTextView = _outputTextView;

	[handle waitForDataInBackgroundAndNotify];

	observer = [[NSNotificationCenter defaultCenter] addObserverForName:
	  NSFileHandleDataAvailableNotification object:handle
	  queue:nil usingBlock:^(NSNotification *__unused note) {

		NSData *data = [handle availableData];

		if (data.length == 0)
			return;

		NSString *line = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

		NSTextView *tv = outputTextView;
		BOOL smartScroll = tv.visibleRect.origin.y + tv.visibleRect.size.height >= tv.bounds.size.height;

		NSString *log = tv.string;
		log = [log stringByAppendingFormat:@"%@line\n", line];
		tv.string = log;

		if (smartScroll)
			[tv scrollToEndOfDocument:self];

		NSLog(@"[OUTPUT] %@", line);

		[handle waitForDataInBackgroundAndNotify];
	}];

	task.terminationHandler = ^(NSTask *__unused endedTask) {
		[self updateGlobalProgress:1];
		[[NSNotificationCenter defaultCenter] removeObserver:observer];
		observer = nil;
	};
////

	[self updateGlobalProgress:0];
	[task launch];

//// Synchronous
//
//	[task waitUntilExit];
//	NSLog(@"Finished");
//
//	NSFileHandle *read = [pipe fileHandleForReading];
//	NSData *dataRead = [read readDataToEndOfFile];
//	NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
//	NSLog(@"output: %@", stringRead);
////






}

- (void)updateGlobalProgress:(double)progress
{
	NSLog(@"Global progress: %lf", progress * 100);
}





- (IBAction)closeButtonAction:(__unused id)sender
{
	[self dismissViewController:self];
}

@end
