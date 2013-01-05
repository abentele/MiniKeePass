//
//  PasswordViewController.h
//  MiniKeePass
//
//  Created by Andreas Bentele on 30.12.12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PasswordViewControllerDelegate;

@interface PasswordViewControllerOSX : NSWindowController <NSTextFieldDelegate>

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, unsafe_unretained) id<PasswordViewControllerDelegate> delegate;

- (id)initWithFilename:(NSString*)fileName;

@end

@protocol PasswordViewControllerDelegate <NSObject>

- (void)didEnterPassword:(NSString*)password keyFile:(NSString*)keyFile;
- (void)didCancelPassword;

@end