// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TATreePopUpButtonCell+IBIntegration.m
//
//  Summary:   Implementation of a set of Interface Builder support methods for
//             the TATreePopUpButtonCell class.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import <Toenail/TATreePopUpButtonCell.h>
#import "TATreePopUpButtonInspector.h"

// ============================================================================

@implementation TATreePopUpButtonCell (IBIntegration)

// --------------------------------------------------------------
- (void) ibPopulateKeyPaths:(NSMutableDictionary *) keyPaths
{
    [super ibPopulateKeyPaths:keyPaths];
    
    [[keyPaths objectForKey:IBAttributeKeyPaths]
     addObjectsFromArray:[NSArray arrayWithObjects:
                          @"noSelectionPlaceholder",
                          @"noContentPlaceholder",
                          nil]];
    
    [[keyPaths objectForKey:IBToOneRelationshipKeyPaths]
     addObjectsFromArray:[NSArray arrayWithObjects:
                          @"delegate",
                          @"dataSource",
                          nil]];

    [[keyPaths objectForKey:IBLocalizableStringKeyPaths]
     addObjectsFromArray:[NSArray arrayWithObjects:
                          @"noSelectionPlaceholder",
                          @"noContentPlaceholder",
                          nil]];
}


// --------------------------------------------------------------
- (void) ibPopulateAttributeInspectorClasses:(NSMutableArray *) classes
{
    [super ibPopulateAttributeInspectorClasses:classes];

    [classes addObject:[TATreePopUpButtonInspector class]];
}

@end
