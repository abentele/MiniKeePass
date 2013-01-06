//
//  Kdb.m
//  KeePass2
//
//  Created by Qiang Yu on 2/13/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "Kdb.h"
#import "UUID.h"

@implementation KdbGroup

@synthesize parent;
@synthesize image;
@synthesize name;
@synthesize groups;
@synthesize entries;
@synthesize creationTime;
@synthesize lastModificationTime;
@synthesize lastAccessTime;
@synthesize expiryTime;
@synthesize canAddEntries;

- (id)init {
    self = [super init];
    if (self) {
        groups = [[NSMutableArray alloc] initWithCapacity:8];
        entries = [[NSMutableArray alloc] initWithCapacity:16];
        canAddEntries = YES;
    }
    return self;
}


- (void)addGroup:(KdbGroup *)group {
    group.parent = self;
    [groups addObject:group];
}

- (void)removeGroup:(KdbGroup *)group {
    group.parent = nil;
    [groups removeObject:group];
}

- (void)moveGroup:(KdbGroup *)group toGroup:(KdbGroup *)toGroup {
    [self removeGroup:group];
    [toGroup addGroup:group];
}

- (KdbEntry*)currentEntryOfCopy:(KdbEntry*)copy {
    KdbEntry *current = nil;
    for (KdbEntry *e in copy.parent.entries) {
        if ([e.uuid.toString isEqualToString:copy.uuid.toString]) {
            current = e;
            break;
        }
    }
    return current;
}

- (void)replaceEntryWithCopy:(KdbEntry *)copy {
    KdbEntry *entryToReplace = [self currentEntryOfCopy:copy];
    //NSLog(@"entryToReplace: %@", entryToReplace.title);
    
    int index = [self.entries indexOfObject:entryToReplace];
    //NSLog(@"index: %d", index);
    [entries replaceObjectAtIndex:index withObject:copy];
}

- (void)addEntry:(KdbEntry *)entry {
    entry.parent = self;
    [entries addObject:entry];
}

- (void)removeEntry:(KdbEntry *)entry {
    entry.parent = nil;
    [entries removeObject:entry];
}

- (void)moveEntry:(KdbEntry *)entry toGroup:(KdbGroup *)toGroup {
    [self removeEntry:entry];
    [toGroup addEntry:entry];
}

- (BOOL)containsGroup:(KdbGroup *)group {
    // Check trivial case where group is passed to itself
    if (self == group) {
        return YES;
    } else {
        // Check subgroups
        for (KdbGroup *subGroup in groups) {
            if ([subGroup containsGroup:group]) {
                return YES;
            }
        }
        return NO;
    }
}

- (NSString*)description {
#if TARGET_OS_IPHONE
    return [NSString stringWithFormat:@"KdbGroup [image=%d, name=%@, creationTime=%@, lastModificationTime=%@, lastAccessTime=%@, expiryTime=%@]", image, name, creationTime, lastModificationTime, lastAccessTime, expiryTime];
#elif TARGET_OS_MAC
    return [NSString stringWithFormat:@"KdbGroup [image=%ld, name=%@, creationTime=%@, lastModificationTime=%@, lastAccessTime=%@, expiryTime=%@]", image, name, creationTime, lastModificationTime, lastAccessTime, expiryTime];
#endif
}

@end


@implementation KdbEntry

@synthesize parent;
@synthesize image;
@synthesize creationTime;
@synthesize lastModificationTime;
@synthesize lastAccessTime;
@synthesize expiryTime;

- (id)copyWithZone:(NSZone *)zone {
    KdbEntry *copy = [[self.class alloc] init];
    NSLog(@"created copy instance: %@", copy);
    copy.uuid = self.uuid;
    copy.parent = self.parent;
    copy.username = self.username;
    copy.password = self.password;
    copy.url = self.url;
    copy.notes = self.notes;
    copy.image = self.image;
    copy.title = [self.title copyWithZone:zone];
    copy.creationTime = [self.creationTime copyWithZone:zone];
    copy.lastModificationTime = [self.lastModificationTime copyWithZone:zone];
    copy.lastAccessTime = [self.lastAccessTime copyWithZone:zone];
    copy.expiryTime = [self.expiryTime copyWithZone:zone];
    NSLog(@"filled copy instance: %@", copy);
    return copy;
}

- (NSString *)title {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setTitle:(NSString *)title {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString *)username {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setUsername:(NSString *)username {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString *)password {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setPassword:(NSString *)password {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString *)url {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setUrl:(NSString *)url {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString *)notes {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setNotes:(NSString *)notes {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString*)description {
    // used also to check the dirty flag => include all attributes
    NSString *imageStr = [NSString stringWithFormat:INT_FORMAT, self.image];
    return [NSString stringWithFormat:@"KdbEntry [image=%@, title=%@, username=%@, password=%@, url=%@, notes=%@, creationTime=%@, lastModificationTime=%@, lastAccessTime=%@, expiryTime=%@]", imageStr, self.title, self.username, self.password, self.url, self.notes, self.creationTime, self.lastModificationTime, self.lastAccessTime, self.expiryTime];
}

- (NSString*)stringRepresentationToCheckDirty {
    NSString *str = [self description];
    // normalize null values
    str = [str stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    return str;
}

@end


@implementation KdbTree

@synthesize root;


- (KdbGroup*)createGroup:(KdbGroup*)parent {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (KdbEntry*)createEntry:(KdbGroup*)parent {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
