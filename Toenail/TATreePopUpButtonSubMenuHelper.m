// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TATreePopUpButtonSubMenuHelper.m
//
//  Summary:   An internal class used by the TATreePopUpButtonCell to manage
//             delay loading of submenus for items in the popup menu.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import "TATreePopUpButtonSubMenuHelper.h"
#import "TATreePopUpButtonCell+SharedPrivate.h"

// ============================================================================

@implementation TATreePopUpButtonSubMenuHelper

// --------------------------------------------------------------
- (id) initWithOwningCell:(id)cell proxyItem:(id)item
{
    if(self = [super init])
    {
        owningCell = cell;
        proxyItem = item;
    }
    
    return self;
}


// --------------------------------------------------------------
- (void) menuNeedsUpdate:(NSMenu *)menu
{
    // Ask the owning cell to add to the new menu the children of the proxy
    // item that it is a submenu of.
    
    [owningCell TA_addChildrenOfProxyItem:proxyItem toMenu:menu];
}

@end
