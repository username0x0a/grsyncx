//
//  Settings.m
//  grsyncx
//
//  Created by Michi on 29/04/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import <os/lock.h>
#import "Foundation.h"
#import "Settings.h"
#import "Notifications.h"
#import "UNXParsable.h"

#define SETTINGS_KEY_PROFILES               "Profiles"
#define SETTINGS_KEY_LAST_USED_PROFILE_ID   "LastUsedProfileID"
#define SETTINGS_KEY_RSYNC_CMD_PATH         "RSyncCommandPath"
// Deprecated
#define __SETTINGS_KEY_LAST_USED_PROFILE    "LastUsedProfile"

NS_ASSUME_NONNULL_BEGIN

@interface Settings ()

@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation Settings

+ (Settings *)shared
{
	static Settings *shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [self new];
	});

	return shared;
}

- (instancetype)init
{
	if (self = [super init])
	{
		_defaults = [NSUserDefaults standardUserDefaults];

		// Migration

		NSDictionary *lastProfileDict = [_defaults dictionaryForKey:@__SETTINGS_KEY_LAST_USED_PROFILE];

		if (lastProfileDict) {
			[_defaults removeObjectForKey:@__SETTINGS_KEY_LAST_USED_PROFILE];
			Profile *migratedProfile = [[Profile alloc] initFromDictionary:lastProfileDict];
			self.profiles = @[ migratedProfile ];
			self.lastUsedProfileUUID = migratedProfile.UUID;
		}

//		[[NSNotificationCenter defaultCenter] addObserver:self
//			selector:@selector(appWillTerminateNotification)
//			name:GRSAppWillTerminateNotification object:nil];
	}

	return self;
}

- (NSArray<Profile *> *)profiles
{
	NSArray<NSDictionary *> *profiles = [_defaults arrayForKey:@SETTINGS_KEY_PROFILES];

	return [NSArrayMapper map:profiles withBlock:^Profile *(NSDictionary *dict) {
		return [[Profile alloc] initFromDictionary:dict];
	}];
}

- (void)setProfiles:(NSArray<Profile *> *)profiles
{
	profiles = profiles ?: @[ ];

	profiles = [NSArrayMapper map:profiles
	  withBlock:^NSDictionary *(Profile *profile) {
		return profile.asDictionary;
	}];

	[_defaults setObject:profiles forKey:@SETTINGS_KEY_PROFILES];
}

- (nullable NSUUID *)lastUsedProfileUUID
{
	NSString *uuidString = [_defaults stringForKey:@SETTINGS_KEY_LAST_USED_PROFILE_ID];

	if (!uuidString) return nil;

	return [[NSUUID alloc] initWithUUIDString:uuidString];
}

- (void)setLastUsedProfileUUID:(nullable NSUUID *)lastUsedProfileUUID
{
	[_defaults setObject:lastUsedProfileUUID.UUIDString forKey:@SETTINGS_KEY_LAST_USED_PROFILE_ID];
}

- (nullable NSString *)rsyncCmdPath
{
	return [_defaults stringForKey:@SETTINGS_KEY_RSYNC_CMD_PATH];
}

- (void)setRsyncCmdPath:(nullable NSString *)rsyncCmdPath
{
	[_defaults setObject:rsyncCmdPath forKey:@SETTINGS_KEY_RSYNC_CMD_PATH];
}

@end

NS_ASSUME_NONNULL_END
