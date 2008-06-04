// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TATreePopUpButton.h
//
//  Summary:   Declaration of the TATreePopUpButton class.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import <Cocoa/Cocoa.h>

// ============================================================================

/*!

 @class TATreePopUpButton
 
 @abstract The TATreePopUpButton class is a subclass of Cocoa's
 NSPopUpButton that displays a hierarchy of items instead of a simple array.
 Items that have children are displayed using submenus, and if a submenu
 item is chosen, it is displayed as a sepcial item at the top of the root
 items, above a separator, so that the popup appearance still works
 properly.

 */
@interface TATreePopUpButton : NSPopUpButton
{
    // Property-backed instance variables
    id delegate;
    id dataSource;
}


// Properties .................................................................

/*!

 @property delegate

 @abstract An object that implements the TATreePopUpButtonDelegate protocol.
 The delegate is not retained.

 */
@property (assign, nonatomic) id delegate;


/*!
 
 @property dataSource
 
 @abstract An object that implements the TATreePopUpButtonDataSource protocol.
 The data source is not retained.
 
 */
@property (assign, nonatomic) id dataSource;


/*!

 @property noSelectionPlaceholder

 @abstract A string that is displayed in the popup button when no item is
 currently selected.

 */
@property (copy, nonatomic) NSString *noSelectionPlaceholder;


/*!

 @property noContentPlaceholder

 @abstract A string that is displayed in the popup button when it has no
 items.

 */
@property (copy, nonatomic) NSString *noContentPlaceholder;


/*!
 
 @property objectValue

 @abstract The currently selected item of the popup button.
 
 */
@property (assign, nonatomic) id objectValue;


@end



// ============================================================================

/*!
 
 @protocol TATreePopUpButtonDataSource
 
 @abstract The TATreePopUpButtonDataSource informal protocol should be
 implemented by classes that will act as a data source for a TATreePopUpButton
 control.
 
 */
@interface NSObject (TATreePopUpButtonDataSource)

/*!
 
 @method treePopUpButton:child:ofItem:
 
 @abstract Returns the child item at the specified index of a given item. If
 item is nil, returns the appropriate child of the root object. This method
 must be implemented.
 
 @param popUpButton the popup button
 @param index the index of the child item to retrieve
 @param item the item whose child should be retrieved
 
 @result the child item

 */
- (id) treePopUpButton:(TATreePopUpButton *) popUpButton
                 child:(int) index
                ofItem:(id) item;


/*!

 @method treePopUpButton:isItemExpandable:

 @abstract Implementors should return YES if the specified item has children
 and should be displayed with a submenu, or NO if the item has no children.
 This method must be implemented.
 
 @param popUpButton the popup button
 @param item the item whose expandable state should be returned
 
 @result YES if the item is expandable (has children), NO if it is not.
 
 */
- (BOOL) treePopUpButton:(TATreePopUpButton *) popUpButton
        isItemExpandable:(id) item;


/*!
 
 @method treePopUpButton:numberOfChildrenOfItem:
 
 @abstract Implementors should return the number of children that the specified
 item has. The popup button will only send this message if
 -treePopUpButton:isItemExpandable: returns YES. This method must be
 implemented.
 
 @param popUpButton the popup button
 @param item the item whose child count should be returned

 @result the number of children of the specified item
 
 */
- (int) treePopUpButton:(TATreePopUpButton *) popUpButton
 numberOfChildrenOfItem:(id) item;


@end



// ============================================================================

/*!
 
 @protocol TATreePopUpButtonDelegate
 
 @abstract The TATreePopUpButtonDelegate informal protocol should be
 implemented by classes that will act as a delegate for a TATreePopUpButton
 control.
 
 */
@interface NSObject (TATreePopUpButtonDelegate)

/*!
 
 @method treePopUpButton:titleForItem:
 
 @abstract Gets the title string to be displayed for the specified item. This
 method is optional; if it is not implemented, the -description method will be
 called on the item to determine its title.
 
 @param button the popup button
 @param item the item

 @result the title string for the item
 
 */
- (NSString *) treePopUpButton:(TATreePopUpButton *)button
                  titleForItem:(id)item;


/*!
 
 @method treePopUpButton:imageForItem:
 
 @abstract Gets an image to display for this item. This method is optional; if
 it is not implemented, no image will be used.
 
 @param button the popup button
 @param item the item
 
 @result the image for the item
 
 */
- (NSImage *) treePopUpButton:(TATreePopUpButton *)button
                 imageForItem:(id)item;


/*!
 
 @method treePopUpButton:isItemEnabled:
 
 @abstract Gets a value indicating whether the item will be enabled. This
 method is optional; if it is not implemented, all items will be enabled.
 
 @param popUpButton the button
 @param item the item
 
 @result YES if the item is enabled; NO if it is not.
 
 */
- (BOOL) treePopUpButton:(TATreePopUpButton *) popUpButton
           isItemEnabled:(id) item;

@end
