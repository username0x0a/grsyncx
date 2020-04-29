//
//  Settings.h
//  grsyncx
//
//  Created by Michi on 29/04/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncProfile.h"

NS_ASSUME_NONNULL_BEGIN

@interface Settings : NSObject

+ (instancetype)new  UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (class, nonatomic, readonly) Settings *shared;

@property (nonatomic, strong) SyncProfile *lastUsedProfile;

@end

NS_ASSUME_NONNULL_END
