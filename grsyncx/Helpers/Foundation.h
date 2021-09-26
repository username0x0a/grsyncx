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

- (instancetype)unx_filtered:(NS_NOESCAPE GRSArrayFilterBlock)block;

@end

@interface NSArrayMapper<InputType, OutputType> : NSObject

+ (NSArray<OutputType> *)map:(NSArray<InputType> *)inputArray withBlock:(OutputType (^)(InputType obj))block;

@end

@interface NSValue (BetterNSCopying)

- (instancetype)copy;

@end

@interface NSString (BetterNSCopying)

- (NSString *)copy;
- (NSMutableString *)mutableCopy;

@end

@interface NSDictionary<KeyType, ObjectType> (BetterNSCopying)

- (NSDictionary<KeyType, ObjectType> *)copy;
- (NSMutableDictionary<KeyType, ObjectType> *)mutableCopy;

@end

@interface NSArray<ObjectType> (BetterNSCopying)

- (NSArray<ObjectType> *)copy;
- (NSMutableArray<ObjectType> *)mutableCopy;

@end

@interface NSSet<__covariant ObjectType> (BetterNSCopying)

- (NSSet<ObjectType> *)copy;
- (NSMutableSet<ObjectType> *)mutableCopy;

@end

@interface NSData (BetterNSCopying)

- (NSData *)copy;
- (NSMutableData *)mutableCopy;

@end

NS_ASSUME_NONNULL_END
