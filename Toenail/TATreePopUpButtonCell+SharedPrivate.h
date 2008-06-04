// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TATreePopUpButtonCell+SharedPrivate.h
//
//  Summary:   Internal methods for the TATreePopUpButtonCell class that need
//             to be accessible both to the button and cell classes, but not
//             publicly visible.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import "TATreePopUpButtonCell.h"

// ============================================================================

@interface TATreePopUpButtonCell (SharedPrivate)

- (void) TA_reset;
- (id) TA_content;
- (void) TA_notifyObserverSelectedObjectChanged;
- (void) TA_popUpButtonCellWillPopUp:(NSNotification *) notification;
- (void) TA_menuDidEndTracking:(NSNotification *) notification;
- (void) TA_menuItemSelected:(id) sender;
- (void) TA_addChildrenOfProxyItem:(id) parentItem toMenu:(NSMenu *) menu;
- (NSMenuItem *) TA_menuItemForNoContent;
- (NSMenuItem *) TA_menuItemForNoSelection;
- (BOOL) TA_isContentBoundToTreeController;
- (int) TA_countOfChildrenOfProxyItem:(id) item;
- (id) TA_child:(int) index ofProxyItem:(id) item;
- (id) TA_representedObjectForProxyItem:(id) item;
- (NSString *) TA_titleForItemFromDelegates:(id) item;
- (NSImage *) TA_imageForItemFromDelegates:(id) item;
- (BOOL) TA_isItemEnabledFromDelegates:(id) item;
- (int) TA_indexOfProxyItemWithRepresentedObject:(id) anObject;
- (NSMenuItem *) TA_menuItemForObject:(id) anObject
                       usingProxyItem:(id) proxyItem;

@end
