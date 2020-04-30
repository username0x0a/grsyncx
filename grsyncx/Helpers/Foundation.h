//
//  Foundation.h
//  grsyncx
//
//  Created by Michi on 30/04/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ElementType> (GRSExtended)

typedef BOOL (^GRSArrayFilterBlock)(ElementType element);

- (instancetype)filteredArrayUsingBlock:(NS_NOESCAPE GRSArrayFilterBlock)block;

@end

NS_ASSUME_NONNULL_END
