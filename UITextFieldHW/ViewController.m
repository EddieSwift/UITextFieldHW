//
//  ViewController.m
//  UITextFieldHW
//
//  Created by Eduard Galchenko on 1/19/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import "ViewController.h"

typedef enum {
    
    EGBLableName,
    EGBLabelSurname,
    EGBLabelLogin,
    EGBLablePassword,
    EGBLabelAge,
    EGBLabelPhone,
    EGBLabelEmail,
    EGBLabelAddress,
    
} EGBLabelType;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.firstNameField becomeFirstResponder];
}

#pragma mark - Actions

- (IBAction)actionTextChanged:(UITextField *)sender {

    UILabel * currentLabel = [self.allAmountOfLabels objectAtIndex:[self.allFields indexOfObject:sender]];
    currentLabel.text = sender.text;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isEqual:self.phoneField]) {
        
        return [self textField:textField checkingPhoneNumber:range replacementString:string];
    }
    
    if ([textField isEqual:self.ageField]) {
        
        return [self textField:textField checkingAge:range replacementString:string];
    }
    
    if ([textField isEqual:self.emailField]) {
        
        return [self textField:textField checkingEmail:range replacementString:string];
    }
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSInteger currentTextField = [self.allFields indexOfObject:textField];
    NSInteger lastAddressField = [self.allFields indexOfObject:[self.allFields lastObject]];

    if (currentTextField < [self.allFields count]) {

        if (currentTextField != lastAddressField) {

            UITextField * nextTextField = self.allFields[currentTextField + 1];
            [nextTextField becomeFirstResponder];

        } else {

            [textField resignFirstResponder];
        }
    }
    
    return YES;
}

#pragma mark - Private Methods

- (BOOL)textField:(UITextField *)textField checkingEmail:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableCharacterSet* alphanumericeSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [alphanumericeSet addCharactersInString:@"@."];
    
    NSCharacterSet* atSet = [alphanumericeSet invertedSet];
    
    NSArray* components = [string componentsSeparatedByCharactersInSet:atSet];
    
    if (components.count > 1) {
        
        return NO;
    }
    
    if ([string containsString:@"@"] && [textField.text containsString:@"@"]) {
        
        NSRange existingRange = [textField.text localizedStandardRangeOfString:@"@"];
        
        if (!NSLocationInRange(existingRange.location, range)) {
            return NO;
        }
        
    }
    
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return newString.length < 30;
}

- (BOOL)textField:(UITextField *)textField checkingAge:(NSRange)range replacementString:(NSString *)string {
    
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSCharacterSet *set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSArray *result = [string componentsSeparatedByCharactersInSet:set];
    
    if ([result count] > 1) {

        return NO;
    }
    
    NSLog(@"Age newString = %@", newString);
    
//    NSInteger checkAgeNumber = [newString intValue];
//
//    if (!(checkAgeNumber > 0 && checkAgeNumber <= 120)) {
//
//        return NO;
//    }
        return YES;
}


- (BOOL)textField:(UITextField *)textField checkingPhoneNumber:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet *validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray *components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        return NO;
    }
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    // +XX (XXX) XXX-XXXX
    NSLog(@"new string: %@", newString);
    
    NSArray *validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];
    newString = [validComponents componentsJoinedByString:@""];
    
    // XXXXXXXXXXXX
    
    NSLog(@"new string fixed: %@", newString);
    
    static const int localNumberMaxLength = 7;
    static const int countryCodeMaxLength = 3;
    static const int areaCodeMaxLength = 3;
    
    if ([newString length] > localNumberMaxLength + countryCodeMaxLength + areaCodeMaxLength) {
        
        return NO;
    }
    
    NSMutableString *resultString = [NSMutableString string];
    
    // +XX (XXX) XXX-XXXX
    
    NSInteger localNumberLength = MIN([newString length], localNumberMaxLength);
    
    if (localNumberLength > 0) {
        
        NSString *number = [newString substringFromIndex:(int)[newString length] - localNumberLength];
        
        [resultString appendString:number];
        
        if ([resultString length] > 3) {
            
            [resultString insertString:@"-" atIndex:3];
        }
    }
    
    if ([newString length] > localNumberMaxLength) {
        
        NSInteger areaCodeLength = MIN([newString length] - localNumberLength, areaCodeMaxLength);
        
        NSRange areaRange = NSMakeRange((int)[newString length] - localNumberMaxLength - areaCodeLength, areaCodeLength);
        
        NSString *area = [newString substringWithRange:areaRange];
        
        area = [NSString stringWithFormat:@"(%@) ", area];
        
        [resultString insertString:area atIndex:0];
    }
    
    if ([newString length] > localNumberMaxLength + areaCodeMaxLength) {
        
        NSInteger countryCodeLength = MIN([newString length] - localNumberLength - areaCodeMaxLength, countryCodeMaxLength);
        
        NSRange countryRange = NSMakeRange(0, countryCodeLength);
        
        NSString *countryCode = [newString substringWithRange:countryRange];
        
        countryCode = [NSString stringWithFormat:@"+%@ ", countryCode];
        
        [resultString insertString:countryCode atIndex:0];
    }
    
    textField.text = resultString;
    
    self.phoneLabel.text = textField.text;
    
    return NO;
}

@end

/*
- (BOOL)textFieldShouldReturn:(UITextField *)textField { // // called when 'return' key pressed. return NO to ignore.
    
    if ([textField isEqual:self.firstNameField]) {
        
        [self.secondNameField becomeFirstResponder];
        
    } else if ([textField isEqual:self.secondNameField]) {
        
        [self.loginField becomeFirstResponder];
        
    } else if ([textField isEqual:self.loginField]) {
        
        [self.passwordField becomeFirstResponder];
        
    } else if ([textField isEqual:self.passwordField]) {
        
        [self.ageField becomeFirstResponder];
        
    } else if ([textField isEqual:self.ageField]) {
        
        [self.phoneField becomeFirstResponder];
        
    } else if ([textField isEqual:self.phoneField]) {
        
        [self.emailField becomeFirstResponder];
        
    } else if ([textField isEqual:self.emailField]) {
        
        [self.addressField becomeFirstResponder];
        
    } else {
        
        [textField resignFirstResponder];
    }
    
    return YES;
}
 */


//    NSUInteger index = [self.allFields indexOfObject:sender];
//
//    UILabel* label = [self.allAmountOfLabels objectAtIndex:index];
//
//    if ([sender.text isEqualToString:@""]) {
//
//        UILabel* titleLabel = [self.allAmountOfLabels objectAtIndex:index];
//        label.text = titleLabel.text;
//
//    } else {
//
//        label.text = sender.text;
//    }
