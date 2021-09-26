//
//  Settings.h
//  grsyncx
//
//  Created by Michi on 29/04/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "Foundation.h"
#import "Profile.h"

NS_ASSUME_NONNULL_BEGIN

@interface Settings : NSObject

@property (nonatomic, copy) NSArray<Profile *> *profiles;
@property (nonatomic, copy, nullable) NSUUID *lastUsedProfileUUID;

@property (nonatomic, copy, nullable) NSString *rsyncCmdPath;

@property (class, nonatomic, readonly) Settings *shared;

+ (instancetype)new  UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
