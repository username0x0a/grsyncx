//
//  UNXParsable.m
//  grsyncx
//
//  Created by Michal Zelinka on 04/12/2019.
//  Copyright © 2019 Michal Zelinka. All rights reserved.
//

#import "UNXParsable.h"


@implementation NSObject (MNKParsableExt)

- (id)unx_parsedAsClass:(Class)cls
{
	return [self isKindOfClass:cls] ? self : nil;
}

- (UNXParsable *)unx_parsable
{
	return [[UNXParsable alloc] initWithObject:self];
}

@end


@interface UNXParsable ()

@property (nonatomic, strong) NSObject *workingObject;

@end

@implementation UNXParsable

- (instancetype)initWithObject:(NSObject *)object
{
	if (self = [super init])
	{
		_workingObject = object;
	}

	return self;
}

- (UNXParsable *)firstObject
{
	NSArray *arr = [_workingObject unx_parsedAsClass:[NSArray class]];

	_workingObject = arr.firstObject;

	if (!_workingObject) return nil;

	return self;
}

- (UNXParsable *)lastObject
{
	NSArray *arr = [_workingObject unx_parsedAsClass:[NSArray class]];

	_workingObject = arr.lastObject;

	if (!_workingObject) return nil;

	return self;
}

- (UNXParsable *)objectAtIndexedSubscript:(NSUInteger)idx
{
	NSArray *arr = [_workingObject unx_parsedAsClass:[NSArray class]];

	_workingObject = (idx < arr.count) ? arr[idx] : nil;

	if (!_workingObject) return nil;

	return self;
}

- (UNXParsable *)objectForKeyedSubscript:(id)key
{
	NSDictionary *dict = [_workingObject unx_parsedAsClass:[NSDictionary class]];

	_workingObject = dict[key];

	if (!_workingObject) return nil;

	return self;
}

- (NSNumber *)number
{
	return [_workingObject unx_parsedAsClass:[NSNumber class]];
}

- (NSString *)string
{
	return [_workingObject unx_parsedAsClass:[NSString class]];
}

- (NSArray *)array
{
	return [_workingObject unx_parsedAsClass:[NSArray class]];
}

- (NSDictionary *)dictionary
{
	return [_workingObject unx_parsedAsClass:[NSDictionary class]];
}

@end


// Naive quick test suite:
//
//int main() {
//
//	NSObject *obj = @128;
//	NSLog(@"%@", obj.mnk_parsable[1]);
//	NSLog(@"%@", obj.mnk_parsable[@"wow"]);
//	NSLog(@"%@", obj.mnk_parsable.number);
//	NSLog(@"%@", obj.mnk_parsable.string);
//	NSLog(@"%@", obj.mnk_parsable.array);
//	NSLog(@"%@", obj.mnk_parsable.dictionary);
//
//	obj = @"ahoj";
//	NSLog(@"%@", obj.mnk_parsable[1]);
//	NSLog(@"%@", obj.mnk_parsable[@"wow"]);
//	NSLog(@"%@", obj.mnk_parsable.number);
//	NSLog(@"%@", obj.mnk_parsable.string);
//	NSLog(@"%@", obj.mnk_parsable.array);
//	NSLog(@"%@", obj.mnk_parsable.dictionary);
//
//	obj = @[ @1, @2 ];
//	NSLog(@"%@", obj.mnk_parsable[1].number);
//	NSLog(@"%@", obj.mnk_parsable[@"wow"]);
//	NSLog(@"%@", obj.mnk_parsable.number);
//	NSLog(@"%@", obj.mnk_parsable.string);
//	NSLog(@"%@", obj.mnk_parsable.array);
//	NSLog(@"%@", obj.mnk_parsable.dictionary);
//
//	obj = @{ @"wow": @YES };
//	NSLog(@"%@", obj.mnk_parsable[1]);
//	NSLog(@"%@", obj.mnk_parsable[@"wow"].number);
//	NSLog(@"%@", obj.mnk_parsable.number);
//	NSLog(@"%@", obj.mnk_parsable.string);
//	NSLog(@"%@", obj.mnk_parsable.array);
//	NSLog(@"%@", obj.mnk_parsable.dictionary);
//
//	return 0;
//}
