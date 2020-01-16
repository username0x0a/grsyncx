//
//  MainViewController.m
//  grsyncx
//
//  Created by Michal Zelinka on 12/01/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "MainViewController.h"
#import "SyncingViewController.h"
#import "WindowActionsResponder.h"

@interface SourceHelpPopupViewController : NSViewController

@end

@interface MainViewController () <WindowActionsResponder>

@property (nonatomic, weak) IBOutlet NSPathControl *sourcePathCtrl;
@property (nonatomic, weak) IBOutlet NSPathControl *destinationPathCtrl;

@property (nonatomic, weak) IBOutlet NSButton *sourcePathChangeButton;
@property (nonatomic, weak) IBOutlet NSButton *destinationPathChangeButton;

// trailing "/" in source path
@property (nonatomic, weak) IBOutlet NSButton *wrapInSourceFolderButton;
@property (nonatomic, weak) IBOutlet NSButton *wrapInSourceFolderHelpButton;

// -t, --times | Preserve time
@property (nonatomic, weak) IBOutlet NSButton *preserveTimeButton;
// -p, --perms | Preserve permissions
@property (nonatomic, weak) IBOutlet NSButton *preservePermissionsButton;
// -o, --owner | Preserve owner (super-user only)
@property (nonatomic, weak) IBOutlet NSButton *preserveOwnerButton;
// -g, --group | Preserve group
@property (nonatomic, weak) IBOutlet NSButton *preserveGroupButton;
// -E | Preserve extended attributes
@property (nonatomic, weak) IBOutlet NSButton *preserveExtAttrsButton;

// --delete | Delete extraneous files from the destination dirs
@property (nonatomic, weak) IBOutlet NSButton *deleteOnDestButton;
// -x, --one-file-system | Don't cross filesystem boundaries
@property (nonatomic, weak) IBOutlet NSButton *dontLeaveFilesystButton;
// -v, --verbose | Increase verbosity
@property (nonatomic, weak) IBOutlet NSButton *verboseButton;
// --progress | Show progress during transfer
@property (nonatomic, weak) IBOutlet NSButton *showTransProgressButton;
// --ignore-existing | Ignore files which already exist in the destination
@property (nonatomic, weak) IBOutlet NSButton *ignoreExistingButton;
// --size-only | Skip file that match in size, ignore time and checksum
@property (nonatomic, weak) IBOutlet NSButton *sizeOnlyButton;
// -u, --update | Skip files that are newer in the destination
@property (nonatomic, weak) IBOutlet NSButton *skipNewerButton;
// --modify-window=1 | Compare modification times with reduced accuracy, workaround for a FAT FS limitation
@property (nonatomic, weak) IBOutlet NSButton *windowsCompatButton;

// -c, --checksum | Skip based on checksum, not time and size
@property (nonatomic, weak) IBOutlet NSButton *alwaysChecksumButton;
// -z, --compress | Compress data during transfer (if one+ side is remote)
@property (nonatomic, weak) IBOutlet NSButton *compressFileDataButton;
// -D | Same as --devices --specials
@property (nonatomic, weak) IBOutlet NSButton *preserveDevicesButton;
// --existing | Only update existing files, skip new
@property (nonatomic, weak) IBOutlet NSButton *existingFilesButton;
// -P | Same as --partial --progress
@property (nonatomic, weak) IBOutlet NSButton *partialTransFilesButton;
// --numeric-ids | Keep numeric UID/GID instead of mapping its names
@property (nonatomic, weak) IBOutlet NSButton *noUIDGIDMapButton;
// -l | Symbolic links are copied as such, do not copy link target file
@property (nonatomic, weak) IBOutlet NSButton *preserveSymlinksButton;
// -H, --hard-links | Hard-links are copied as such, do not copy link target file
@property (nonatomic, weak) IBOutlet NSButton *preserveHardLinksButton;
// -b, --backup | Make backups of existing files in the destination, see --suffix & --backup-dir
@property (nonatomic, weak) IBOutlet NSButton *makeBackupsButton;
// -i, --itemize-changes | Show additional information on every changed file
@property (nonatomic, weak) IBOutlet NSButton *showItemizedChangesButton;
// -d (vs -r) | If checked, source subdirectories will be ignored
@property (nonatomic, weak) IBOutlet NSButton *disableRecursionButton;
// -s | Protect remote args from shell expansion, avoids the need to manually escape filename args like --exclude
@property (nonatomic, weak) IBOutlet NSButton *protectRemoteArgsButton;

@property (nonatomic, weak) IBOutlet NSTextView *additionalOptsTextView;

@property (atomic) BOOL runSimulated;

@end

@implementation MainViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	// rsync --stats
	// rsync --itemize-changes:
	// http://www.staroceans.org/e-book/understanding-the-output-of-rsync-itemize-changes.html

	_sourcePathCtrl.URL = [NSURL fileURLWithPath:NSHomeDirectory()];
	_additionalOptsTextView.font = [NSFont userFixedPitchFontOfSize:13];

	_sourcePathCtrl.layer.cornerRadius = 4;
	_destinationPathCtrl.layer.cornerRadius = 4;
}


- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}


#pragma mark - Actions


- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = title ?: @"";
	alert.informativeText = message ?: @"";
	alert.alertStyle = NSAlertStyleCritical;
	[alert addButtonWithTitle:NSLocalizedString(@"Close", @"Button title")];
	[alert beginSheetModalForWindow:self.view.window completionHandler:nil];
}


#pragma mark - UI actions


- (IBAction)pickFolder:(id)sender
{
	NSString *title = nil;
	NSPathControl *pathCtrl = nil;

	if (sender == _sourcePathChangeButton || sender == _sourcePathCtrl) {
		title = NSLocalizedString(@"Select Source folder", @"View label");
		pathCtrl = _sourcePathCtrl;
	} else {
		title = NSLocalizedString(@"Select Destination folder", @"View label");
		pathCtrl = _destinationPathCtrl;
	}

	BOOL pickingDest = pathCtrl == _destinationPathCtrl;

	NSOpenPanel *panel = [NSOpenPanel openPanel];
	panel.title = title;
	panel.directoryURL = pathCtrl.URL;
	panel.canChooseDirectories = YES;
	panel.canCreateDirectories = YES;
	panel.canChooseFiles = !pickingDest;
	panel.allowsMultipleSelection = NO;

	[panel beginSheetModalForWindow:self.view.window
	  completionHandler:^(NSModalResponse result) {
		if (result == NSModalResponseOK)
			pathCtrl.URL = panel.URLs.firstObject;
	}];
}

- (IBAction)displayHelp:(id)sender
{
	SourceHelpPopupViewController *vc = [[SourceHelpPopupViewController alloc] init];

	NSRect rect = [sender convertRect:[sender bounds] toView:self.view];

	NSPopover *helpPopover = [NSPopover new];
	helpPopover.contentSize = vc.preferredContentSize;
	helpPopover.behavior = NSPopoverBehaviorTransient;;
	helpPopover.animates = YES;
	helpPopover.contentViewController = vc;
	[helpPopover showRelativeToRect:rect ofView:self.view preferredEdge:NSRectEdgeMaxX];
}


#pragma mark - Rsync command


- (NSArray<NSString *> *)collectArguments
{
	NSMutableArray<NSString *> *args = [NSMutableArray arrayWithCapacity:32];

	#define isOn(btn) (btn.state == NSControlStateValueOn)

	if (isOn(_preserveTimeButton))           [args addObject:@"-t"];
	if (isOn(_preservePermissionsButton))    [args addObject:@"-p"];
	if (isOn(_preserveOwnerButton))          [args addObject:@"-o"];
	if (isOn(_preserveGroupButton))          [args addObject:@"-g"];
	if (isOn(_preserveExtAttrsButton))       [args addObject:@"-E"];

	if (isOn(_deleteOnDestButton))           [args addObject:@"--delete"];
	if (isOn(_dontLeaveFilesystButton))      [args addObject:@"-x"];
	if (isOn(_verboseButton))                [args addObject:@"-v"];
	if (isOn(_showTransProgressButton))      [args addObject:@"--progress"];
	if (isOn(_ignoreExistingButton))         [args addObject:@"--ignore-existing"];
	if (isOn(_sizeOnlyButton))               [args addObject:@"--size-only"];
	if (isOn(_skipNewerButton))              [args addObject:@"--update"];
	if (isOn(_windowsCompatButton))          [args addObject:@"--modify-window=1"];

	if (isOn(_alwaysChecksumButton))         [args addObject:@"--checksum"];
	if (isOn(_compressFileDataButton))       [args addObject:@"--compress"];
	if (isOn(_preserveDevicesButton))        [args addObject:@"-D"];
	if (isOn(_existingFilesButton))          [args addObject:@"--existing"];
	if (isOn(_partialTransFilesButton))      [args addObject:@"-P"];
	if (isOn(_noUIDGIDMapButton))            [args addObject:@"--numeric-ids"];
	if (isOn(_preserveSymlinksButton))       [args addObject:@"-l"];
	if (isOn(_preserveHardLinksButton))      [args addObject:@"-H"];
	if (isOn(_makeBackupsButton))            [args addObject:@"--backup"];
	if (isOn(_showItemizedChangesButton))    [args addObject:@"-i"];

	if (isOn(_disableRecursionButton))       [args addObject:@"-d"];
	else                                     [args addObject:@"-r"];

	if (isOn(_protectRemoteArgsButton))      [args addObject:@"-s"];

	NSArray<NSString *> *additionalArgs =
	[[_additionalOptsTextView.textStorage.string
	  componentsSeparatedByString:@" "] filteredArrayUsingPredicate:
	 [NSPredicate predicateWithBlock:^BOOL(NSString *arg,
	  NSDictionary<NSString *,id> *__unused bindings) {
		return arg.length > 0;
	}]];

	if (additionalArgs.count)
		[args addObjectsFromArray:additionalArgs];

	return [args copy];
}

- (void)collectCurrentOptionsWithCompletion:(void (NS_NOESCAPE ^)(SyncingOptions *, NSString *))completion
{
	if (!completion) return;

	NSURL *srcURL = _sourcePathCtrl.pathItems.lastObject.URL;
	NSURL *dstURL = _destinationPathCtrl.pathItems.lastObject.URL;

	NSString *err = nil;

	if (!srcURL)
		err = NSLocalizedString(@"Source path isn't set", @"View label");
	else if (!dstURL)
		err = NSLocalizedString(@"Destination path isn't set", @"View label");

	if (err)
	{
		completion(nil, err);
		return;
	}

	NSMutableArray<NSString *> *args = [[self collectArguments] mutableCopy];

	if (_runSimulated)
		[args addObject:@"-n"];

	NSString *srcPath = srcURL.path;
	NSString *dstPath = dstURL.path;

	if (_wrapInSourceFolderButton.state == NSControlStateValueOff)
		srcPath = [srcPath stringByAppendingString:@"/"];

	SyncingOptions *options = [SyncingOptions new];
	options.sourcePath = srcPath;
	options.destinationPath = dstPath;
	options.arguments = args;

	completion(options, nil);
}

- (void)prepareForSegue:(__unused NSStoryboardSegue *)segue sender:(__unused id)sender
{
	if ([segue.identifier isEqualToString:@"SyncingSegue"])
	{
		SyncingViewController *vc = segue.destinationController;

		if (![vc isKindOfClass:[SyncingViewController class]])
			return;

		[self collectCurrentOptionsWithCompletion:
		 ^(SyncingOptions *options, __unused NSString *err) {
			vc.syncingOptions = options;
		}];
	}
}

- (void)runRsyncSimulated:(BOOL)simulated
{
	_runSimulated = simulated;

	[self collectCurrentOptionsWithCompletion:
	 ^(__unused SyncingOptions * opts, NSString *error) {

		if (error) [self showAlertWithTitle:error message:nil];
		else [self performSegueWithIdentifier:@"SyncingSegue" sender:nil];

	}];
}


#pragma mark - Syncing options handler


- (SyncingOptions *)syncingOptions
{
	__block SyncingOptions *options = nil;

	[self collectCurrentOptionsWithCompletion:
	 ^(SyncingOptions *collected, __unused NSString *err) {
		options = collected;
	}];

	return options;
}


#pragma mark - Window actions responder


- (void)didReceiveSimulateAction
{
	[self runRsyncSimulated:YES];
}

- (void)didReceiveExecuteAction
{
	[self runRsyncSimulated:NO];
}


@end


@implementation SourceHelpPopupViewController

- (void)loadView
{
//	CGFloat inset = 12;
//	CGRect frame = CGRectMake(inset, inset, size.width-2*inset, size.height-2*inset);
//
//	NSTextField *desc = [[NSTextField alloc] initWithFrame:frame];
//	desc.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
//	desc.editable = NO;
//	desc.selectable = NO;
//	desc.backgroundColor = [NSColor clearColor];
//	desc.bezeled = NO; desc.bordered = NO;
//	desc.stringValue = NSLocalizedString(@"This settings allows to wrap contents of "
//		"the Source directory within a folder in the Destination path named same as "
//		"the Source directory.\n\nIf you have a couple of `example.*` files in your "
//		"Source path, wrapping them will put them to a `Destination/Source/example.*` "
//		"path.\n\nWithout wrapping, these files will be included directly at the "
//		"`Destination/example.*` path.", @"Source wrap popup help description");
//	[view addSubview:desc];

	NSImage *image = [NSImage imageNamed:@"source_wrap_hint"];

	CGSize size = self.preferredContentSize;
	NSView *view = self.view = [[NSView alloc] initWithFrame:
		NSRectFromCGRect(CGRectMake(0, 0, size.width, size.height))];

	NSImageView *imageView = [NSImageView imageViewWithImage:image];
	imageView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

	CGRect imgFrame = imageView.frame;
	imgFrame.size = size;
	imgFrame.origin.x = round((size.width - imgFrame.size.width)/2);
	imgFrame.origin.y = round((size.height - imgFrame.size.height)/2);
	imageView.frame = imgFrame;
	[view addSubview:imageView];
}

- (NSSize)preferredContentSize
{
	return CGSizeMake(512, 192);
}

@end
