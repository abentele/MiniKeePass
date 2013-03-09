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

#import "StringFieldViewController.h"

@implementation StringFieldViewController

- (id)initWithStringField:(StringField *)stringField {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.stringField = stringField;

        self.title = NSLocalizedString(@"Custom Field", nil);

        self.keyTextField = [[UITextField alloc] init];
        self.keyTextField.placeholder = NSLocalizedString(@"Name", nil);
        self.keyTextField.returnKeyType = UIReturnKeyNext;
        self.keyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.keyTextField.delegate = self;
        self.keyTextField.text = stringField.key;

        self.valueTextField = [[UITextField alloc] init];
        self.valueTextField.placeholder = NSLocalizedString(@"Value", nil);
        self.valueTextField.returnKeyType = UIReturnKeyDone;
        self.valueTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.valueTextField.delegate = self;
        self.valueTextField.text = stringField.value;

        self.protectedSwitchCell = [[SwitchCell alloc] initWithLabel:NSLocalizedString(@"In Memory Protection", nil)];
        self.protectedSwitchCell.switchControl.on = stringField.protected;

        self.controls = @[_keyTextField, _valueTextField, _protectedSwitchCell];
        self.delegate = self;
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _keyTextField) {
        [self.valueTextField becomeFirstResponder];
    } else if (textField == _valueTextField) {
        [self okPressed:nil];
    }

    return YES;
}

- (void)okPressed:(id)sender {
    if (self.keyTextField.text.length == 0) {
        NSString *title = NSLocalizedString(@"Name cannot be empty", nil);
        NSString *ok = NSLocalizedString(@"OK", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
        [alert show];
        return;
    }

    [super okPressed:sender];
}

- (void)formViewController:(FormViewController *)controller button:(FormViewControllerButton)button {
    if (button == FormViewControllerButtonOk) {
        _stringField.key = _keyTextField.text;
        _stringField.value = _valueTextField.text;
        _stringField.protected = _protectedSwitchCell.switchControl.on;

        if ([_stringFieldViewDelegate respondsToSelector:@selector(stringFieldViewController:updateStringField:)]) {
            [_stringFieldViewDelegate stringFieldViewController:self updateStringField:_stringField];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
