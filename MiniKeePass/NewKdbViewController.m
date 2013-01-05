/*
 * Copyright 2011-2012 Jason Rush and John Flanagan. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "NewKdbViewController.h"

#define VSPACER 12
#define HSPACER 9
#define BUTTON_WIDTH (320 - 2 * HSPACER)
#define BUTTON_HEIGHT 32

@implementation NewKdbViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.headerTitle = NSLocalizedString(@"New Database", nil);
        
        self.nameTextField = [[UITextField alloc] init];
        self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.nameTextField.placeholder = NSLocalizedString(@"Name", nil);
        self.nameTextField.returnKeyType = UIReturnKeyNext;
        self.nameTextField.delegate = self;
        
        self.passwordTextField1 = [[UITextField alloc] init];
        self.passwordTextField1.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.passwordTextField1.placeholder = NSLocalizedString(@"Password", nil);
        self.passwordTextField1.secureTextEntry = YES;
        self.passwordTextField1.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.passwordTextField1.autocorrectionType = UITextAutocorrectionTypeNo;
        self.passwordTextField1.returnKeyType = UIReturnKeyNext;
        self.passwordTextField1.delegate = self;
        
        self.passwordTextField2 = [[UITextField alloc] init];
        self.passwordTextField2.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.passwordTextField2.placeholder = NSLocalizedString(@"Confirm Password", nil);
        self.passwordTextField2.secureTextEntry = YES;
        self.passwordTextField2.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.passwordTextField2.autocorrectionType = UITextAutocorrectionTypeNo;
        self.passwordTextField2.returnKeyType = UIReturnKeyDone;
        self.passwordTextField2.delegate = self;

        self.versionSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Version 1.x", nil), NSLocalizedString(@"Version 2.x", nil), nil]];
        self.versionSegmentedControl.selectedSegmentIndex = 0;
        self.versionSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        self.versionSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	  	
        self.navigationItem.titleView = self.versionSegmentedControl;
        
        self.controls = [NSArray arrayWithObjects:self.nameTextField, self.passwordTextField1, self.passwordTextField2, nil];
        self.tableView.scrollEnabled = YES;
    }
    return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {    
    CGPoint point = [self.tableView convertPoint:CGPointZero fromView:textField];
     UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForRowAtPoint:point]];
    [self.tableView scrollRectToVisible:cell.frame animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [self.passwordTextField1 becomeFirstResponder];
    } else if (textField == self.passwordTextField1) {
        [self.passwordTextField2 becomeFirstResponder];
    } else if (textField == self.passwordTextField2) {
        [self okPressed:nil];
    }
    
    return YES;
}

@end
