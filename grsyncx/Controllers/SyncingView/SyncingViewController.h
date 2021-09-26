//
//  SyncingViewController.h
//  grsyncx
//
//  Created by Michal Zelinka on 14/01/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "Profile.h"

NS_ASSUME_NONNULL_BEGIN

@interface SyncingViewController : NSViewController

@property (nonatomic, strong, nullable) Profile *profile;

@end

NS_ASSUME_NONNULL_END
