//
//  Foundation.m
//  grsyncx
//
//  Created by Michi on 30/04/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "Foundation.h"

@implementation NSArray (GRSExtended)

- (instancetype)filteredArrayUsingBlock:(BOOL (NS_NOESCAPE ^)(id _Nonnull))block
{
	return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:
	  ^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable __unused bindings) {
		return (evaluatedObject) ? block(evaluatedObject) : FALSE;
	}]];
}

@end
