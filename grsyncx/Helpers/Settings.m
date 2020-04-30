//
//  Settings.m
//  grsyncx
//
//  Created by Michi on 29/04/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "Settings.h"
#import "Notifications.h"
#import "UNXParsable.h"

@interface Settings ()

@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation Settings

+ (Settings *)shared
{
	static Settings *shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[self alloc] init];
	});

	return shared;
}

- (instancetype)init
{
	if (self = [super init])
	{
		_defaults = [NSUserDefaults standardUserDefaults];

		NSDictionary *lastProfile = [_defaults dictionaryForKey:@SETTINGS_KEY_LAST_USED_PROFILE];
		_lastUsedProfile = [[SyncProfile alloc] initFromDictionary:lastProfile] ?: [SyncProfile defaultProfile];

		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(appWillTerminateNotification)
			name:GRSAppWillTerminateNotification object:nil];
	}

	return self;
}

- (void)appWillTerminateNotification
{
	[self saveSettings];
}

- (void)saveSettings
{
	[_defaults setObject:_lastUsedProfile.asDictionary forKey:@SETTINGS_KEY_LAST_USED_PROFILE];
}

@end
