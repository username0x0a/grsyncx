//
//  Foundation.m
//  grsyncx
//
//  Created by Michi on 30/04/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import "Foundation.h"

@implementation NSArray (GRSExtended)

- (instancetype)unx_filtered:(BOOL (NS_NOESCAPE ^)(id _Nonnull))block
{
	return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:
	  ^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable __unused bindings) {
		return (evaluatedObject) ? block(evaluatedObject) : FALSE;
	}]];
}

@end

@implementation NSArrayMapper

+ (NSArray *)map:(NSArray *)inputArray withBlock:(id (^)(id))block
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:inputArray.count];

	id mapped = nil;
	for (id obj in inputArray)
		if ((mapped = block(obj)))
			[array addObject:mapped];

	return [array copy];
}

@end
