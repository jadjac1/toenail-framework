// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TATreePopUpButtonSubMenuHelper.h
//
//  Summary:   An internal class used by the TATreePopUpButtonCell to manage
//             delay loading of submenus for items in the popup menu.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import <Cocoa/Cocoa.h>

// ============================================================================

@interface TATreePopUpButtonSubMenuHelper : NSObject
{
    id owningCell;
    id proxyItem;
}

- (id) initWithOwningCell:(id)cell proxyItem:(id)proxyItem;
- (void) menuNeedsUpdate:(NSMenu *)menu;

@end
