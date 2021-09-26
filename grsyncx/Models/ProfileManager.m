//
//  ProfileManager.m
//  grsyncx
//
//  Created by Michal Zelinka on 11/01/2021.
//  Copyright © 2021 Michal Zelinka. All rights reserved.
//

#import "ProfileManager.h"
#import "Settings.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileManager ()

@property (nonatomic, weak) Settings *settings;

@property (nonatomic, copy) NSArray<Profile *> *profiles;

@end

@implementation ProfileManager

+ (instancetype)shared
{
	static ProfileManager *shared = nil;
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
		_settings = [Settings shared];
		_profiles = _settings.profiles;
	}

	return self;
}

- (NSArray<ReadonlyProfile *> *)allProfiles
{
	return self.profiles;
}

- (nullable ReadonlyProfile *)lastUsedProfile
{
	return [self profileWithUUID:_settings.lastUsedProfileUUID];
}

- (nullable ReadonlyProfile *)profileWithUUID:(NSUUID *)UUID
{
	if (UUID)
		for (Profile *p in self.profiles)
			if ([p.UUID isEqual:UUID])
				return p;

	return nil;
}

- (void)updateLastUsedProfileWithUUID:(NSUUID *)UUID
{
	_settings.lastUsedProfileUUID = UUID;
}

- (void)updateProfileWithUUID:(NSUUID *)UUID withValuesFromProfile:(ReadonlyProfile *)profile
{
	Profile *updatedProfile = (id)[self profileWithUUID:UUID];

	if (!updatedProfile)
		self.profiles = [self.profiles arrayByAddingObject:(id)profile];
	else {
		updatedProfile.name = profile.name;
		updatedProfile.sourcePath = profile.sourcePath;
		updatedProfile.destinationPath = profile.destinationPath;
		updatedProfile.wrapInSourceFolder = profile.wrapInSourceFolder;
		updatedProfile.basicProperties = profile.basicProperties;
		updatedProfile.advancedProperties = profile.advancedProperties;
		updatedProfile.additionalOptions = profile.additionalOptions;
		updatedProfile.simulatedRun = profile.simulatedRun;
	}

	_settings.profiles = self.profiles;
}

@end

NS_ASSUME_NONNULL_END
