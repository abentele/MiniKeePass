//
//  KDB.h
//  KeePass2
//
//  Created by Qiang Yu on 1/1/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_TRANSFORMATION_ROUNDS 6000

#if TARGET_OS_IPHONE
#define INT_FORMAT @"%d"
#elif TARGET_OS_MAC
#define INT_FORMAT @"%ld"
#endif

@class KdbEntry;
@class UUID;

@interface KdbGroup : NSObject {
}

@property(nonatomic, strong) KdbGroup *parent;

@property(nonatomic, assign) NSInteger image;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, readonly) NSArray *groups;
@property(nonatomic, readonly) NSArray *entries;

@property(nonatomic, strong) NSDate *creationTime;
@property(nonatomic, strong) NSDate *lastModificationTime;
@property(nonatomic, strong) NSDate *lastAccessTime;
@property(nonatomic, strong) NSDate *expiryTime;

@property(nonatomic, assign) BOOL canAddEntries;

- (void)addGroup:(KdbGroup *)group;
- (void)removeGroup:(KdbGroup *)group;
- (void)moveGroup:(KdbGroup *)group toGroup:(KdbGroup *)toGroup;

- (KdbEntry*)currentEntryOfCopy:(KdbEntry*)copy;
- (void)replaceEntryWithCopy:(KdbEntry *)copy;
- (void)addEntry:(KdbEntry *)entry;
- (void)removeEntry:(KdbEntry *)entry;
- (void)moveEntry:(KdbEntry *)entry toGroup:(KdbGroup *)toGroup;

- (BOOL)containsGroup:(KdbGroup*)group;

@end

@interface KdbEntry : NSObject <NSCopying> {
}

@property(nonatomic, strong) UUID *uuid;
@property(nonatomic, strong) KdbGroup *parent;
@property(nonatomic, assign) NSInteger image;

- (NSString *)title;
- (void)setTitle:(NSString *)title;

- (NSString *)username;
- (void)setUsername:(NSString *)username;

- (NSString *)password;
- (void)setPassword:(NSString *)password;

- (NSString *)url;
- (void)setUrl:(NSString *)url;

- (NSString *)notes;
- (void)setNotes:(NSString *)notes;

@property(nonatomic, strong) NSDate *creationTime;
@property(nonatomic, strong) NSDate *lastModificationTime;
@property(nonatomic, strong) NSDate *lastAccessTime;
@property(nonatomic, strong) NSDate *expiryTime;

- (NSString*)stringRepresentationToCheckDirty;

@end

@interface KdbTree : NSObject {
    KdbGroup *root;
}

@property(nonatomic, strong) KdbGroup *root;

- (KdbGroup*)createGroup:(KdbGroup*)parent;
- (KdbEntry*)createEntry:(KdbGroup*)parent;

@end
