// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TATreePopUpButtonFakeProxyItem.m
//
//  Summary:   An internal class used by the TATreePopUpButtonCell to create a
//             "fake" proxy item in instances where an item does not come
//             directly from its bound tree controller -- for example, if the
//             selected object is set manually.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import "TATreePopUpButtonFakeProxyItem.h"

// ============================================================================

@implementation TATreePopUpButtonFakeProxyItem

// --------------------------------------------------------------
- (id) initWithRepresentedObject:(id) anObject
{
    if(self = [super init])
    {
        representedObject = anObject;
    }
    
    return self;
}


// --------------------------------------------------------------
- (id) representedObject
{
    return representedObject;
}

@end
