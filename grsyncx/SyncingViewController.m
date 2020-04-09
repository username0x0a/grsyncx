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

@property (nonatomic, weak) IBOutlet NSProgressIndicator *globProgressIndicator;
@property (nonatomic, weak) IBOutlet NSTextView *outputTextView;

@property (nonatomic, weak) IBOutlet NSButton *stopButton;
@property (nonatomic, weak) IBOutlet NSButton *closeButton;

@property (nonatomic, strong) NSTask *task;
@property (nonatomic, strong) NSPipe *pipe;
@property (nonatomic, strong) id observer;

@end


@implementation SyncingViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	_outputTextView.font = [NSFont userFixedPitchFontOfSize:11];
}

- (void)viewWillAppear
{
	[super viewWillAppear];

	NSWindow *window = self.view.window;
	window.title = NSLocalizedString(@"Synchronisation", @"Window title");
	window.minSize = self.view.bounds.size;

	_outputTextView.textContainer.widthTracksTextView = NO;
	_outputTextView.textContainer.containerSize =
		NSSizeFromCGSize(CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX));
}

- (void)viewDidAppear
{
	[self executeRsync];
}


#pragma mark - Actions


- (void)updateGlobalProgress:(double)progress
{
	progress = MIN(MAX(progress, 0), 1);
	dispatch_async(dispatch_get_main_queue(), ^{
		self->_globProgressIndicator.doubleValue = progress * 100;
		if (progress >= 1) {
			self->_stopButton.enabled = NO;
			self->_closeButton.enabled = YES;
		}
	});
	NSLog(@"Global progress: %lf", progress * 100);
}

- (IBAction)stopButtonAction:(id)sender
{
	[self terminateRsync];
}

- (IBAction)closeButtonAction:(id)sender
{
	[self dismissViewController:self];
}


#pragma mark - Command line stuff


- (void)executeRsync
{
	// rsync --stats
	// rsync --itemize-changes:
	// http://www.staroceans.org/e-book/understanding-the-output-of-rsync-itemize-changes.html

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

	static NSUInteger totalFiles = 0;
	static id observer = nil;
	static NSUInteger blockCounter = 0;
	static BOOL checkingToCheck = NO;
	blockCounter = 0;

	NSFileHandle *handle = pipe.fileHandleForReading;
	NSTextView *outputTextView = _outputTextView;

	[handle waitForDataInBackgroundAndNotify];

	observer = [[NSNotificationCenter defaultCenter] addObserverForName:
	  NSFileHandleDataAvailableNotification object:handle
	  queue:nil usingBlock:^(NSNotification *__unused note) {

		NSData *data = [handle availableData];

		if (data.length == 0 || !observer)
			return;

		NSString *line = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
		NSString *cons = @" files to consider";
		NSString *toCheck = @" to-check=";

		if ([line containsString:cons])
		{
			NSArray<NSString *> *lines = [line componentsSeparatedByString:@"\n"];
			for (NSString *ln in lines)
				if ([ln containsString:cons])
					totalFiles = (NSUInteger)[ln doubleValue];
		}

		if (totalFiles > 0)
		{
			if ([line containsString:toCheck]) {
				checkingToCheck = YES;
				NSUInteger remaining = (NSUInteger)[line
					componentsSeparatedByString:toCheck].lastObject.integerValue;
				blockCounter = totalFiles-remaining;
			}
			else if (!checkingToCheck)
				blockCounter += [line componentsSeparatedByString:@"\n"].count;

			double progress = MIN(MAX((double)blockCounter / (double)totalFiles, 0), 0.99);

			dispatch_async(dispatch_get_main_queue(), ^{
				[self updateGlobalProgress:progress];
			});
		}

		NSTextView *tv = outputTextView;
		BOOL smartScroll = tv.visibleRect.origin.y + tv.visibleRect.size.height >= tv.bounds.size.height;

		NSAttributedString *str = [[NSAttributedString alloc] initWithString:line attributes:@{
			NSFontAttributeName: tv.font,
			NSForegroundColorAttributeName: tv.textColor,
		}];

		[tv.textStorage appendAttributedString:str];

		if (smartScroll)
			[tv scrollToEndOfDocument:self];

		NSLog(@"[OUTPUT] %@", line);

		[handle waitForDataInBackgroundAndNotify];
	}];

	__weak typeof(self) ws = self;

	task.terminationHandler = ^(NSTask *__unused endedTask) {
		[[NSNotificationCenter defaultCenter] removeObserver:observer];
		observer = nil;
		dispatch_async(dispatch_get_main_queue(), ^{
			typeof(self) ss = ws;
			[ss updateGlobalProgress:1]; // TODO: Stopped vs Finished state
		});
	};

/// Asynchronous end

	_observer = observer;
	_task = task;
	_pipe = pipe;

	[self updateGlobalProgress:0];
	[task launch];

/// Synchronous
//
//	[task waitUntilExit];
//	NSLog(@"Finished");
//
//	NSFileHandle *read = [pipe fileHandleForReading];
//	NSData *dataRead = [read readDataToEndOfFile];
//	NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
//	NSLog(@"output: %@", stringRead);
//
/// Synchronous end
}

- (void)terminateRsync
{
	[_task terminate];
}

@end
