// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TATreePopUpButtonFakeProxyItem.h
//
//  Summary:   An internal class used by the TATreePopUpButtonCell to create a
//             "fake" proxy item in instances where an item does not come
//             directly from its bound tree controller -- for example, if the
//             selected object is set manually.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import <Cocoa/Cocoa.h>

// ============================================================================

@interface TATreePopUpButtonFakeProxyItem : NSObject
{
    id representedObject;
}

- (id) initWithRepresentedObject:(id) anObject;
- (id) representedObject;

@end
