// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TAFontField+IBIntegration.m
//
//  Summary:   Implementation of a set of Interface Builder support methods for
//             the TAFontField class.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import <Toenail/TAFontField.h>
#import "TAFontFieldInspector.h"

// ============================================================================

@implementation TAFontField (IBIntegration)

// --------------------------------------------------------------
- (void) ibPopulateKeyPaths:(NSMutableDictionary *) keyPaths
{
    [super ibPopulateKeyPaths:keyPaths];
    
    [[keyPaths objectForKey:IBAttributeKeyPaths]
     addObjectsFromArray:[NSArray arrayWithObjects:
                          @"selectedFont",
                          @"selectedFontDescriptor",
                          @"selectedAttributes",
                          nil]];
}


// --------------------------------------------------------------
- (void) ibPopulateAttributeInspectorClasses:(NSMutableArray *) classes
{
    [super ibPopulateAttributeInspectorClasses:classes];

    [classes addObject:[TAFontFieldInspector class]];
}

@end
