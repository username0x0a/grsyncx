//
//  ProfileManager.h
//  grsyncx
//
//  Created by Michal Zelinka on 11/01/2021.
//  Copyright © 2021 Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Profile.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileManager : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new  UNAVAILABLE_ATTRIBUTE;
+ (instancetype)shared;

- (NSArray<ReadonlyProfile *> *)allProfiles;

- (nullable ReadonlyProfile *)lastUsedProfile;

- (nullable ReadonlyProfile *)profileWithUUID:(NSUUID *)UUID;

- (void)updateLastUsedProfileWithUUID:(NSUUID *)UUID;

- (void)updateProfileWithUUID:(NSUUID *)UUID withValuesFromProfile:(ReadonlyProfile *)profile;

@end

NS_ASSUME_NONNULL_END
