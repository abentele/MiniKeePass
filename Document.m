//
//  Document.m
//  Test
//
//  Created by Andreas Bentele on 30.12.12.
//  Copyright (c) 2012 Andreas Bentele. All rights reserved.
//

#import "Document.h"
#import "AppSettings.h"
#import "Kdb.h"
#import "KdbPassword.h"
#import "KdbReaderFactory.h"


@interface Document ()

@property (nonatomic, retain) KdbTree *kdbTree;
@property (nonatomic, retain) KdbPassword *kdbPassword;
@property (nonatomic, assign) IBOutlet NSOutlineView *outlineView;

@end

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
    [self.outlineView expandItem:self.kdbTree.root];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL databaseLoaded = NO;
    
    // Load the password and keyfile from the keychain
    NSString *password = @"";
    NSString *keyFile = nil;
    
    // Try and load the database with the cached password from the keychain
    if (password != nil || keyFile != nil) {
        // TODO
        // Get the absolute path to the keyfile
/*        NSString *keyFilePath = nil;
        if (keyFile != nil) {
            keyFilePath = [documentsDirectory stringByAppendingPathComponent:keyFile];
        }*/
        
        // Load the database
        @try {
            NSStringEncoding passwordEncoding = [[AppSettings sharedInstance] passwordEncoding];
            
            self.kdbPassword = [[KdbPassword alloc] initWithPassword:password
                                               passwordEncoding:passwordEncoding
                                                        keyFile:keyFile];
            
            self.kdbTree = [KdbReaderFactory load:absoluteURL withPassword:self.kdbPassword];

            databaseLoaded = YES;
        } @catch (NSException * exception) {
            NSLog(@"Error loading keepass 2.x file: %@", exception);
        }
    }
    
    // TODO
    /*
    // Prompt the user for the password if we haven't loaded the database yet
    if (!databaseLoaded) {
        // Prompt the user for a password
        PasswordViewController *passwordViewController = [[PasswordViewController alloc] initWithFilename:filename];
        passwordViewController.delegate = self;
        
        // Create a defult keyfile name from the database name
        keyFile = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"key"];
        
        // Select the keyfile if it's in the list
        NSInteger index = [passwordViewController.keyFileCell.choices indexOfObject:keyFile];
        if (index != NSNotFound) {
            passwordViewController.keyFileCell.selectedIndex = index;
        } else {
            passwordViewController.keyFileCell.selectedIndex = 0;
        }
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:passwordViewController];
        
        [appDelegate.window.rootViewController presentModalViewController:navigationController animated:animated];
        
        [navigationController release];
        [passwordViewController release];
    }
     */
    return YES;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        item = self.kdbTree.root;
    }
    
    if ([item isKindOfClass:[KdbGroup class]]) {
        KdbGroup *group = (KdbGroup*)item;
        return [[group groups] count] + [[group entries] count];
    }
    
    return 0;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [item isKindOfClass:[KdbGroup class]];
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        item = self.kdbTree.root;
    }

    KdbGroup *group = (KdbGroup*)item;
    if (index < group.groups.count) {
        return [group.groups objectAtIndex:index];
    }
    else {
        return [group.entries objectAtIndex:index - group.groups.count];
    }
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[KdbGroup class]]) {
        KdbGroup *group = (KdbGroup*)item;
        if ([tableColumn.identifier isEqualToString:@"title"]) {
            return group.name;
        }
    }
    else if ([item isKindOfClass:[KdbEntry class]]) {
        KdbEntry *entry = (KdbEntry*)item;
        if ([tableColumn.identifier isEqualToString:@"title"]) {
            return entry.title;
        }
        else if ([tableColumn.identifier isEqualToString:@"username"]) {
            return entry.username;
        }
        else if ([tableColumn.identifier isEqualToString:@"url"]) {
            return entry.url;
        }
    }
    return @"";
}

@end
