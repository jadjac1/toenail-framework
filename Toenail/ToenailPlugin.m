// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      ToenailPlugin.m
//
//  Summary:   Implementation of the ToenailPlugin class, the IBPlugin subclass
//             for Toenail.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import "ToenailPlugin.h"

// ============================================================================

@implementation Toenail

// --------------------------------------------------------------
- (NSArray *) libraryNibNames
{
    return [NSArray arrayWithObject:@"ToenailLibrary"];
}


// --------------------------------------------------------------
- (NSArray*)requiredFrameworks 
{ 
    NSBundle* frameworkBundle = [NSBundle bundleWithIdentifier:
                                 @"com.tonyallevato.ToenailFramework"]; 
    return [NSArray arrayWithObject:frameworkBundle]; 
} 

@end
