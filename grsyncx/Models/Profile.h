//
//  Profile.h
//  grsyncx
//
//  Created by Michi on 24/04/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Properties

typedef NS_OPTIONS(NSUInteger, RSyncBasicProp) {
	RSyncBasicPropNone = 0,
	// -t, --times | Preserve time
	RSyncBasicPropPreserveTime = (1 << 0),
	// -p, --perms | Preserve permissions
	RSyncBasicPropPreservePermissions = (1 << 1),
	// -o, --owner | Preserve owner (super-user only)
	RSyncBasicPropPreserveOwner = (1 << 2),
	// -g, --group | Preserve group
	RSyncBasicPropPreserveGroup = (1 << 3),
	// -E | Preserve extended attributes
	RSyncBasicPropPreserveExtAttrs = (1 << 4),
	// --delete | Delete extraneous files from the destination dirs
	RSyncBasicPropDeleteOnDest = (1 << 5),
	// -x, --one-file-system | Don't cross filesystem boundaries
	RSyncBasicPropDontLeaveFilesyst = (1 << 6),
	// -v, --verbose | Increase verbosity
	RSyncBasicPropVerbose = (1 << 7),
	// --progress | Show progress during transfer
	RSyncBasicPropShowTransProgress = (1 << 8),
	// --ignore-existing | Ignore files which already exist in the destination
	RSyncBasicPropIgnoreExisting = (1 << 9),
	// --size-only | Skip file that match in size, ignore time and checksum
	RSyncBasicPropSizeOnly = (1 << 10),
	// -u, --update | Skip files that are newer in the destination
	RSyncBasicPropSkipNewer = (1 << 11),
	// --modify-window=1 | Compare modification times with reduced accuracy,
	//                     workaround for a FAT FS limitation
	RSyncBasicPropWindowsCompat = (1 << 12),
};

typedef NS_OPTIONS(NSUInteger, RSyncAdvancedProp) {
	RSyncAdvancedPropNone = 0,
	// -c, --checksum | Skip based on checksum, not time and size
	RSyncAdvancedPropAlwaysChecksum = (1 << 0),
	// -z, --compress | Compress data during transfer (if one+ side is remote)
	RSyncAdvancedPropCompressFileData = (1 << 1),
	// -D | Same as --devices --specials
	RSyncAdvancedPropPreserveDevices = (1 << 2),
	// --existing | Only update existing files, skip new
	RSyncAdvancedPropExistingFiles = (1 << 3),
	// -P | Same as --partial --progress
	RSyncAdvancedPropPartialTransFiles = (1 << 4),
	// --numeric-ids | Keep numeric UID/GID instead of mapping its names
	RSyncAdvancedPropNoUIDGIDMap = (1 << 5),
	// -l | Symbolic links are copied as such, do not copy link target file
	RSyncAdvancedPropPreserveSymlinks = (1 << 6),
	// -H, --hard-links | Hard-links are copied as such, do not copy link target file
	RSyncAdvancedPropPreserveHardLinks = (1 << 7),
	// -b, --backup | Make backups of existing files in the destination,
	//                see --suffix & --backup-dir
	RSyncAdvancedPropMakeBackups = (1 << 8),
	// -i, --itemize-changes | Show additional information on every changed file
	RSyncAdvancedPropShowItemizedChanges = (1 << 9),
	// -d (vs -r) | If checked, source subdirectories will be ignored
	RSyncAdvancedPropDisableRecursion = (1 << 10),
	// -s | Protect remote args from shell expansion, avoids the need to
	//      manually escape filename args like --exclude
	RSyncAdvancedPropProtectRemoteArgs = (1 << 11),
};

#pragma mark - Profile (Read-only protocol)

@protocol GRReadonlyProfile <NSObject>

@property (nonatomic, copy, readonly) NSUUID *UUID;
@property (nonatomic, copy, readonly, nullable) NSString *name;

@property (nonatomic, copy, readonly, nullable) NSString *sourcePath;
@property (nonatomic, copy, readonly, nullable) NSString *destinationPath;

@property (atomic, readonly) BOOL wrapInSourceFolder;

@property (atomic, readonly) RSyncBasicProp basicProperties;
@property (atomic, readonly) RSyncAdvancedProp advancedProperties;

@property (nonatomic, copy, readonly, nullable) NSString *additionalOptions;

@property (atomic, readonly) BOOL simulatedRun;

@end

#pragma mark - Profile

typedef NSObject<GRReadonlyProfile> ReadonlyProfile;

@interface Profile : NSObject <NSCopying, GRReadonlyProfile>

#pragma mark Initializers

- (instancetype)initFromDictionary:(NSDictionary *)dict;
- (NSDictionary *)asDictionary;

#pragma mark Properties

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new  UNAVAILABLE_ATTRIBUTE;
+ (instancetype)defaultProfile;

@property (nonatomic, copy) NSUUID *UUID;
@property (nonatomic, copy, nullable) NSString *name;

@property (nonatomic, copy, nullable) NSString *sourcePath;
@property (nonatomic, copy, nullable) NSString *destinationPath;

// trailing "/" in source path
@property (atomic) BOOL wrapInSourceFolder;

@property (atomic) RSyncBasicProp basicProperties;
@property (atomic) RSyncAdvancedProp advancedProperties;

@property (nonatomic, copy, nullable) NSString *additionalOptions;

#pragma mark Temporary properties

@property (atomic) BOOL simulatedRun;

#pragma mark Methods

@property (nonatomic, copy, readonly) NSString *displayableName;
@property (nonatomic, copy, readonly, nullable) NSString *calculatedSourcePath;
@property (nonatomic, copy, readonly, nullable) NSString *calculatedDestinationPath;
@property (nonatomic, copy, readonly, nullable) NSArray<NSString *> *calculatedArguments;

@end

NS_ASSUME_NONNULL_END
