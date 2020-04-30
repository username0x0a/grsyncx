//
//  UNXParsable.h
//  grsyncx
//
//  Created by Michal Zelinka on 04/12/2019.
//  Copyright © 2019 Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface UNXParsable : NSObject

@property (nonatomic, readonly, nullable) NSNumber *number;
@property (nonatomic, readonly, nullable) NSString *string;
@property (nonatomic, readonly, nullable) NSArray *array;
@property (nonatomic, readonly, nullable) NSDictionary *dictionary;

+ (instancetype)new  UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithObject:(NSObject *)object;

- (nullable UNXParsable *)firstObject;
- (nullable UNXParsable *)lastObject;
- (nullable UNXParsable *)objectAtIndexedSubscript:(NSUInteger)idx;
- (nullable UNXParsable *)objectForKeyedSubscript:(id)key;

@end


@interface NSObject (UNXParsableExt)

@property (nonatomic, readonly) UNXParsable *unx_parsable;

- (nullable id)unx_parsedAsClass:(Class)cls;

@end


NS_ASSUME_NONNULL_END
