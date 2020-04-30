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

#import "SyncProfile.h"
#import "Settings.h"

#import <pwd.h>


#pragma mark - Helping popup controllers -


@interface SourceHelpPopupViewController : NSViewController @end
@interface PermissionsHelpPopupViewController : NSViewController @end


#pragma mark - Main view controller -


@interface MainViewController () <WindowActionsResponder>

#pragma mark General

@property (nonatomic, strong) Settings *settings;

#pragma mark Basic properties

@property (nonatomic, weak) IBOutlet NSPathControl *sourcePathCtrl;
@property (nonatomic, weak) IBOutlet NSPathControl *destinationPathCtrl;

@property (nonatomic, weak) IBOutlet NSButton *sourcePathPermissionButton;
@property (nonatomic, weak) IBOutlet NSButton *sourcePathChangeButton;
@property (nonatomic, weak) IBOutlet NSButton *destinationPathChangeButton;

@property (nonatomic, weak) IBOutlet NSButton *wrapInSourceFolderButton;
@property (nonatomic, weak) IBOutlet NSButton *wrapInSourceFolderHelpButton;

@property (nonatomic, weak) IBOutlet NSButton *preserveTimeButton;
@property (nonatomic, weak) IBOutlet NSButton *preservePermissionsButton;
@property (nonatomic, weak) IBOutlet NSButton *preserveOwnerButton;
@property (nonatomic, weak) IBOutlet NSButton *preserveGroupButton;
@property (nonatomic, weak) IBOutlet NSButton *preserveExtAttrsButton;

@property (nonatomic, weak) IBOutlet NSButton *deleteOnDestButton;
@property (nonatomic, weak) IBOutlet NSButton *dontLeaveFilesystButton;
@property (nonatomic, weak) IBOutlet NSButton *verboseButton;
@property (nonatomic, weak) IBOutlet NSButton *showTransProgressButton;
@property (nonatomic, weak) IBOutlet NSButton *ignoreExistingButton;
@property (nonatomic, weak) IBOutlet NSButton *sizeOnlyButton;
@property (nonatomic, weak) IBOutlet NSButton *skipNewerButton;
@property (nonatomic, weak) IBOutlet NSButton *windowsCompatButton;

#pragma mark Advanced properties

@property (nonatomic, weak) IBOutlet NSButton *alwaysChecksumButton;
@property (nonatomic, weak) IBOutlet NSButton *compressFileDataButton;
@property (nonatomic, weak) IBOutlet NSButton *preserveDevicesButton;
@property (nonatomic, weak) IBOutlet NSButton *existingFilesButton;
@property (nonatomic, weak) IBOutlet NSButton *partialTransFilesButton;
@property (nonatomic, weak) IBOutlet NSButton *noUIDGIDMapButton;
@property (nonatomic, weak) IBOutlet NSButton *preserveSymlinksButton;
@property (nonatomic, weak) IBOutlet NSButton *preserveHardLinksButton;
@property (nonatomic, weak) IBOutlet NSButton *makeBackupsButton;
@property (nonatomic, weak) IBOutlet NSButton *showItemizedChangesButton;
@property (nonatomic, weak) IBOutlet NSButton *disableRecursionButton;
@property (nonatomic, weak) IBOutlet NSButton *protectRemoteArgsButton;

@property (nonatomic, weak) IBOutlet NSTextView *additionalOptsTextView;

#pragma mark Execution type

@property (atomic) BOOL runSimulated;

@end


#pragma mark - Implementation


@implementation MainViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	_settings = [Settings shared];

	NSString *homePath = [self userHomeFolderPath];

	_sourcePathCtrl.URL = [NSURL fileURLWithPath:homePath];
	_additionalOptsTextView.font = [NSFont userFixedPitchFontOfSize:13];

	_sourcePathCtrl.layer.cornerRadius = 4;
	_destinationPathCtrl.layer.cornerRadius = 4;

	_sourcePathPermissionButton.hidden = [self hasFullDiskAccess];

	// Reload last used profile
	[self applySyncProfile:_settings.lastUsedProfile];
}

- (void)viewWillDisappear
{
	[super viewWillDisappear];

	_settings.lastUsedProfile = [self syncProfileForCurrentValues];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}


#pragma mark - Profiles handling


- (void)applySyncProfile:(SyncProfile *)profile
{
	NSString *path = nil;
	NSURL *srcURL = nil;
	NSURL *dstURL = nil;

	if ((path = profile.sourcePath))
		srcURL = [NSURL fileURLWithPath:path];
	if ((path = profile.destinationPath))
		dstURL = [NSURL fileURLWithPath:path];

	_sourcePathCtrl.URL = srcURL;
	_destinationPathCtrl.URL = dstURL;
	_wrapInSourceFolderButton.state = profile.wrapInSourceFolder ?
		NSControlStateValueOn : NSControlStateValueOff;

	RSyncBasicProp basicProps = profile.basicProperties;
	RSyncAdvancedProp advProps = profile.advancedProperties;

	#define HAS(x) ((x) > 0)

	[[self basicPropertiesMapping] enumerateKeysAndObjectsUsingBlock:
	 ^(NSNumber *key, NSButton *obj, BOOL *__unused stop) {
		obj.state = HAS(basicProps & key.unsignedIntegerValue) ?
			NSControlStateValueOn : NSControlStateValueOff;
	}];

	[[self advancedPropertiesMapping] enumerateKeysAndObjectsUsingBlock:
	 ^(NSNumber *key, NSButton *obj, BOOL *__unused stop) {
		obj.state = HAS(advProps & key.unsignedIntegerValue) ?
			NSControlStateValueOn : NSControlStateValueOff;
	}];

	_additionalOptsTextView.string = profile.additionalOptions ?: @"";
}

- (SyncProfile *)syncProfileForCurrentValues
{
	SyncProfile *prof = [SyncProfile new];

	NSURL *srcURL = _sourcePathCtrl.pathItems.lastObject.URL;
	NSURL *dstURL = _destinationPathCtrl.pathItems.lastObject.URL;

	prof.sourcePath = srcURL.path;
	prof.destinationPath = dstURL.path;
	prof.wrapInSourceFolder = _wrapInSourceFolderButton.state == NSControlStateValueOn;

	__block RSyncBasicProp basicProps = RSyncBasicPropNone;
	__block RSyncAdvancedProp advProps = RSyncAdvancedPropNone;

	#define HAS(x) ((x) > 0)

	[[self basicPropertiesMapping] enumerateKeysAndObjectsUsingBlock:
	 ^(NSNumber *key, NSButton *obj, BOOL *__unused stop) {
		if (obj.state == NSControlStateValueOn)
			basicProps |= key.unsignedIntegerValue;
	}];

	[[self advancedPropertiesMapping] enumerateKeysAndObjectsUsingBlock:
	 ^(NSNumber *key, NSButton *obj, BOOL *__unused stop) {
		if (obj.state == NSControlStateValueOn)
			advProps |= key.unsignedIntegerValue;
	}];

	prof.basicProperties = basicProps;
	prof.advancedProperties = advProps;

	NSString *additional = _additionalOptsTextView.string;
	if (additional.length)
		prof.additionalOptions = additional;

	prof.simulatedRun = _runSimulated;

	return prof;
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


#pragma mark - Helpers


- (BOOL)isSandboxed
{
	static BOOL sandbox = NO;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sandbox = [[NSProcessInfo processInfo] environment]
		          [@"APP_SANDBOX_CONTAINER_ID"] != nil;
	});

	return sandbox;
}

- (NSString *)userHomeFolderPath
{
	static NSString *homeFolder;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{

		if ([self isSandboxed])
		{
			struct passwd *pw = getpwuid(getuid());
			assert(pw);
			homeFolder = [NSString stringWithUTF8String:pw->pw_dir];
		}
		else homeFolder = NSHomeDirectory();

	});

	return homeFolder;
}

- (BOOL)hasFullDiskAccess
{
	NSString *home = [self userHomeFolderPath];
	NSString *path;

	if (@available(macOS 10.15, *))
	     path = @"Library/Safari/CloudTabs.db";
	else path = @"Library/Safari/Bookmarks.plist";

	path = [home stringByAppendingPathComponent:path];

	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	NSData *data = [NSData dataWithContentsOfFile:path];

	if (data == nil && fileExists)
		return NO; // Denied
	if (fileExists)
		return YES; // Authorized
	return NO; // Not determined
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

- (IBAction)displaySourceHelp:(id)sender
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

- (IBAction)displayPermissionsHelp:(id)sender
{
	PermissionsHelpPopupViewController *vc = [[PermissionsHelpPopupViewController alloc] init];

	NSRect rect = [sender convertRect:[sender bounds] toView:self.view];

	NSPopover *helpPopover = [NSPopover new];
	helpPopover.contentSize = vc.preferredContentSize;
	helpPopover.behavior = NSPopoverBehaviorTransient;;
	helpPopover.animates = YES;
	helpPopover.contentViewController = vc;
	[helpPopover showRelativeToRect:rect ofView:self.view preferredEdge:NSRectEdgeMaxX];
}


#pragma mark - Rsync command

- (NSDictionary<NSNumber *, NSButton *> *)basicPropertiesMapping
{
	return @{
		@(RSyncBasicPropPreserveTime): _preserveTimeButton,
		@(RSyncBasicPropPreservePermissions): _preservePermissionsButton,
		@(RSyncBasicPropPreserveOwner): _preserveOwnerButton,
		@(RSyncBasicPropPreserveGroup): _preserveGroupButton,
		@(RSyncBasicPropPreserveExtAttrs): _preserveExtAttrsButton,
		@(RSyncBasicPropDeleteOnDest): _deleteOnDestButton,
		@(RSyncBasicPropDontLeaveFilesyst): _dontLeaveFilesystButton,
		@(RSyncBasicPropVerbose): _verboseButton,
		@(RSyncBasicPropShowTransProgress): _showTransProgressButton,
		@(RSyncBasicPropIgnoreExisting): _ignoreExistingButton,
		@(RSyncBasicPropSizeOnly): _sizeOnlyButton,
		@(RSyncBasicPropSkipNewer): _skipNewerButton,
		@(RSyncBasicPropWindowsCompat): _windowsCompatButton,
	};
}

- (NSDictionary<NSNumber *, NSButton *> *)advancedPropertiesMapping
{
	return @{
		@(RSyncAdvancedPropAlwaysChecksum): _alwaysChecksumButton,
		@(RSyncAdvancedPropCompressFileData): _compressFileDataButton,
		@(RSyncAdvancedPropPreserveDevices): _preserveDevicesButton,
		@(RSyncAdvancedPropExistingFiles): _existingFilesButton,
		@(RSyncAdvancedPropPartialTransFiles): _partialTransFilesButton,
		@(RSyncAdvancedPropNoUIDGIDMap): _noUIDGIDMapButton,
		@(RSyncAdvancedPropPreserveSymlinks): _preserveSymlinksButton,
		@(RSyncAdvancedPropPreserveHardLinks): _preserveHardLinksButton,
		@(RSyncAdvancedPropMakeBackups): _makeBackupsButton,
		@(RSyncAdvancedPropShowItemizedChanges): _showItemizedChangesButton,
		@(RSyncAdvancedPropDisableRecursion): _disableRecursionButton,
		@(RSyncAdvancedPropProtectRemoteArgs): _protectRemoteArgsButton,
	};
}

- (void)collectCurrentProfileWithCompletion:(void (NS_NOESCAPE ^)(SyncProfile *, NSString *))completion
{
	if (!completion) return;

	SyncProfile *currentProfile = [self syncProfileForCurrentValues];

	NSString *err = nil;

	NSString *srcPath = currentProfile.sourcePath;
	NSString *dstPath = currentProfile.destinationPath;
	BOOL isDirectory = NO;

	if (!srcPath)
		err = NSLocalizedString(@"Source path isn't set", @"View label");
	else if (!dstPath)
		err = NSLocalizedString(@"Destination path isn't set", @"View label");

	if (err) {
		completion(nil, err);
		return;
	}

	NSFileManager *fm = [NSFileManager defaultManager];

	if (![fm fileExistsAtPath:srcPath])
		err = NSLocalizedString(@"Source path is invalid", @"View label");
	else if (![fm fileExistsAtPath:dstPath isDirectory:&isDirectory] || !isDirectory)
		err = NSLocalizedString(@"Destination path is invalid", @"View label");

	if (err) {
		completion(nil, err);
		return;
	}

	completion(currentProfile, nil);
}

- (void)prepareForSegue:(__unused NSStoryboardSegue *)segue sender:(__unused id)sender
{
	if ([segue.identifier isEqualToString:@"SyncingSegue"])
	{
		SyncingViewController *vc = segue.destinationController;

		if (![vc isKindOfClass:[SyncingViewController class]])
			@throw @"Unexpected view controller";

		[self collectCurrentProfileWithCompletion:
		 ^(SyncProfile *profile, NSString *__unused error) {
			vc.profile = profile;
		}];
	}
}

- (void)runRsyncSimulated:(BOOL)simulated
{
	_runSimulated = simulated;

	[self collectCurrentProfileWithCompletion:
	 ^(SyncProfile *__unused profile, NSString *error) {

		if (error) [self showAlertWithTitle:error message:nil];
		else [self performSegueWithIdentifier:@"SyncingSegue" sender:nil];

	}];
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


#pragma mark - Source help popup controller -


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


#pragma mark - Permissions help popup controller -


@implementation PermissionsHelpPopupViewController

- (void)loadView
{
	CGFloat inset = 12;
	CGSize size = self.preferredContentSize;
	CGRect frame = CGRectMake(inset, inset, size.width-2*inset, size.height-2*inset);
	NSView *view = self.view = [[NSView alloc] initWithFrame:
		NSRectFromCGRect(CGRectMake(0, 0, size.width, size.height))];

	NSTextField *desc = [[NSTextField alloc] initWithFrame:frame];
	desc.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	desc.editable = NO;
	desc.selectable = NO;
	desc.backgroundColor = [NSColor clearColor];
	desc.bezeled = NO; desc.bordered = NO;
	desc.stringValue = NSLocalizedString(@"macOS keeps your files implicitly safe by "
		"requiring additional permissions before apps can read its contents. You might "
		"be asked for these permissions at any time during the synchronization.\n\n"
		"To make the synchronization process easier, you can grant grsyncx Full Disk "
		"Access in System Preferences → Security & Privacy → Privacy tab.\n\nThis "
		"step is completely optional.", @"File permissions popup help description");
	[view addSubview:desc];
}

- (NSSize)preferredContentSize
{
	return CGSizeMake(320, 188);
}

@end
