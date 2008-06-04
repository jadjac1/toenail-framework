// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TATreePopUpButtonCell.m
//
//  Summary:   Implementation of the TATreePopUpButtonCell class.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import "TATreePopUpButton.h"
#import "TATreePopUpButton+SharedPrivate.h"
#import "TATreePopUpButtonCell.h"
#import "TATreePopUpButtonCell+SharedPrivate.h"
#import "TATreePopUpButtonSubMenuHelper.h"
#import "TATreePopUpButtonFakeProxyItem.h"

// ============================================================================

static NSString *TANoSelectionPlaceholderKey = @"TANoSelectionPlaceholder";
static NSString *TANoContentPlaceholderKey = @"TANoContentPlaceholder";

static void *ContentObsCtx = (void *)0x1001;
static void *SelectedObjectObsCtx = (void *)0x1002;

// ============================================================================

@implementation TATreePopUpButtonCell

// --------------------------------------------------------------

// Property synthesizers

@synthesize delegate;
@synthesize dataSource;
@synthesize noContentPlaceholder;
@synthesize noSelectionPlaceholder;
@synthesize objectValue;


// --------------------------------------------------------------
- (void) bind:(NSString *) bindingName
     toObject:(id) observableController
  withKeyPath:(NSString *) keyPath
      options:(NSDictionary *) options
{
    if([bindingName isEqualToString:NSContentBinding])
    {
        // If the observed object is an NSTreeController and the user has only
        // specified "arrangedObjects" as the start of the keypath without also
        // including "childNodes", we add it here for convenience.

        if([observableController isKindOfClass:[NSTreeController class]] &&
           [keyPath hasPrefix:@"arrangedObjects"] &&
           ![keyPath hasPrefix:@"arrangedObjects.childNodes"])
        {
            keyPath = [@"arrangedObjects.childNodes"
                       stringByAppendingString:[keyPath substringFromIndex:15]];
        }

        [observableController addObserver:self
                               forKeyPath:keyPath 
                                  options:0
                                  context:ContentObsCtx];
    }
    else if([bindingName isEqualToString:NSSelectedObjectBinding])
    {
        [observableController addObserver:self
                               forKeyPath:keyPath 
                                  options:0
                                  context:SelectedObjectObsCtx];
    }
    
    [super bind:bindingName
       toObject:observableController
    withKeyPath:keyPath
        options:options];
}


// --------------------------------------------------------------
- (void) unbind:(NSString *) bindingName
{
    if([bindingName isEqualToString:NSContentBinding])
    {
        NSDictionary *info = [self infoForBinding:NSContentBinding];
        id object = [info objectForKey:NSObservedObjectKey];
        NSString *keyPath = [info objectForKey:NSObservedKeyPathKey];
        
        [object removeObserver:self forKeyPath:keyPath];
    }
    else if([bindingName isEqualToString:NSSelectedObjectBinding])
    {
        NSDictionary *info = [self infoForBinding:NSSelectedObjectBinding];
        id object = [info objectForKey:NSObservedObjectKey];
        NSString *keyPath = [info objectForKey:NSObservedKeyPathKey];
        
        [object removeObserver:self forKeyPath:keyPath];
    }
    
    [super unbind:bindingName];
}


// --------------------------------------------------------------
- (void) observeValueForKeyPath:(NSString *) keyPath
                       ofObject:(id) object
                         change:(NSDictionary *) change
                        context:(void *) context
{
    id newValue = [object valueForKeyPath:keyPath];

    if(context == ContentObsCtx)
    {
        // Update our local copy of the content object.
        
        [self TA_reset];
    }
    else if(context == SelectedObjectObsCtx)
    {
        // Update the local reference to the selected object and reflect the
        // new selection in the cell.

        objectValue = newValue;
        [self TA_reset];
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


// --------------------------------------------------------------
- (id) initTextCell:(NSString *) stringValue pullsDown:(BOOL) pullDown
{
    if(self = [super initTextCell:stringValue pullsDown:pullDown])
    {
        [self setAutoenablesItems:NO];
        [self setUsesItemFromMenu:NO];
        [self TA_reset];
    }
    
    return self;
}


// --------------------------------------------------------------
- (id) init
{
    return [self initTextCell:@"" pullsDown:NO];
}


// --------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)coder
{
    if(self = [super initWithCoder:coder])
    {
        [self setNoSelectionPlaceholder:
         [coder decodeObjectForKey:TANoSelectionPlaceholderKey]];
        [self setNoContentPlaceholder:
         [coder decodeObjectForKey:TANoContentPlaceholderKey]];
        
        [self setAutoenablesItems:NO];
        [self setUsesItemFromMenu:NO];

        [self TA_reset];
    }
    
    return self;
}


// --------------------------------------------------------------
- (void) encodeWithCoder:(NSCoder *)coder
{
    [self removeAllItems];
    
    [super encodeWithCoder:coder];
    
    [coder encodeObject:[self noSelectionPlaceholder]
                 forKey:TANoSelectionPlaceholderKey];
    [coder encodeObject:[self noContentPlaceholder]
                 forKey:TANoContentPlaceholderKey];
}


// --------------------------------------------------------------
- (id) copyWithZone:(NSZone *) zone
{
    NSLog(@"old object value = %@", self.objectValue);
    
    NSMenuItem *oldMenuItem = [self menuItem];
    [self setMenuItem:nil];

    TATreePopUpButtonCell *copy = [super copyWithZone:zone];

    [self setMenuItem:oldMenuItem];

    copy->objectValue = nil;
    copy.objectValue = self.objectValue;

    copy->noSelectionPlaceholder = nil;
    copy.noSelectionPlaceholder = self.noSelectionPlaceholder;
    
    copy->noContentPlaceholder = nil;
    copy.noContentPlaceholder = self.noContentPlaceholder;

    NSLog(@"new object value = %@", copy.objectValue);

    return copy;
}


// --------------------------------------------------------------
- (void) dealloc
{
    [self unbind:NSContentBinding];
    [self unbind:NSSelectedObjectBinding];

    [self setMenuItem:nil];

    delegate = nil;
    dataSource = nil;
    objectValue = nil;

    [noSelectionPlaceholder release];
    [noContentPlaceholder release];
    
    [super dealloc];
}


// --------------------------------------------------------------
- (void) setDelegate:(id) aDelegate
{
    delegate = aDelegate;
    
    [self TA_reset];
}


// --------------------------------------------------------------
- (void) setDataSource:(id) aDataSource
{
    dataSource = aDataSource;
    
    [self TA_reset];
}


// --------------------------------------------------------------
- (void) setNoContentPlaceholder:(NSString *) aString
{
    if(noContentPlaceholder != aString)
    {
        [noContentPlaceholder release];
        noContentPlaceholder = [aString copy];
        
        [self TA_reset];
    }
}


// --------------------------------------------------------------
- (void) setNoSelectionPlaceholder:(NSString *) aString
{
    if(noSelectionPlaceholder != aString)
    {
        [noSelectionPlaceholder release];
        noSelectionPlaceholder = [aString copy];
        
        [self TA_reset];
    }
}


// --------------------------------------------------------------
- (void) setObjectValue:(id)anObject
{
    objectValue = anObject;
        
    [self TA_reset];
    [self TA_notifyObserverSelectedObjectChanged];
}


// --------------------------------------------------------------
- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
    return YES;
}


// --------------------------------------------------------------
- (void) setTitle:(NSString *) aString
{
    // This method just ignores the specified title (because it doesn't make
    // sense to set the title when the items come from a data source) and
    // updates the cell's menu item based on the current selection.

    NSMenuItem *menuItem;

    int count = [self TA_countOfChildrenOfProxyItem:nil];

    if(count == 0)
    {
        menuItem = [self TA_menuItemForNoContent];
    }
    else if(objectValue == nil)
    {
        menuItem = [self TA_menuItemForNoSelection];
    }
    else
    {
        menuItem = [self TA_menuItemForObject:objectValue usingProxyItem:nil];
    }

    [self setMenuItem:menuItem];
}

@end


// ============================================================================

@implementation TATreePopUpButtonCell (SharedPrivate)

// --------------------------------------------------------------
- (void) TA_reset
{
    // This message is sent when the popup button is initialized or when the
    // selection changes. It removes all the items from the popup menu and adds
    // a single item representing the current selection.
    
    [self removeAllItems];
    
    NSMenuItem *menuItem;
    
    int count = [self TA_countOfChildrenOfProxyItem:nil];
    
    if(count == 0)
    {
        menuItem = [self TA_menuItemForNoContent];
    }
    else if(objectValue == nil)
    {
        menuItem = [self TA_menuItemForNoSelection];
    }
    else
    {
        menuItem = [self TA_menuItemForObject:objectValue usingProxyItem:nil];
    }
    
    [[self menu] addItem:menuItem];
    
    // Register ourselves to pick up notifications when the popup menu is
    // about to appear so that we can populate it with items from the
    // data source.
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center removeObserver:self
                      name:NSPopUpButtonCellWillPopUpNotification
                    object:self];

    [center addObserver:self
               selector:@selector(TA_popUpButtonCellWillPopUp:)
                   name:NSPopUpButtonCellWillPopUpNotification
                 object:self];
}


// --------------------------------------------------------------
- (id) TA_content
{
    NSDictionary *info = [self infoForBinding:NSContentBinding];
    
    if(info)
    {
        id object = [info objectForKey:NSObservedObjectKey];
        NSString *keyPath = [info objectForKey:NSObservedKeyPathKey];
        
        if(object && keyPath)
        {
            return [object valueForKeyPath:keyPath];
        }
    }
    else
    {
        if([[self controlView] isKindOfClass:[TATreePopUpButton class]])
        {
            info = [[self controlView] infoForBinding:NSContentBinding];
            
            if(info)
            {
                id object = [info objectForKey:NSObservedObjectKey];
                NSString *keyPath = [info objectForKey:NSObservedKeyPathKey];
                
                if(object && keyPath)
                {
                    return [object valueForKeyPath:keyPath];
                }
            }
        }
    }
    
    return nil;
}


// --------------------------------------------------------------
- (void) TA_notifyObserverSelectedObjectChanged
{
    NSDictionary *info = [self infoForBinding:NSSelectedObjectBinding];

    if(info)
    {
        id object = [info objectForKey:NSObservedObjectKey];
        NSString *keyPath = [info objectForKey:NSObservedKeyPathKey];
        
        if(object && keyPath)
        {
            id oldValue = [object valueForKeyPath:keyPath];
            if(oldValue != objectValue)
            {
                [object setValue:objectValue forKeyPath:keyPath];
            }
        }
    }

    // Pass the notification up to the owning control if it is a tree pop up
    // button so that it can process it if it, rather than the cell, has the
    // binding.
    
    if([[self controlView] isKindOfClass:[TATreePopUpButton class]])
    {
        [(TATreePopUpButton*)[self controlView]
         TA_notifyObserverSelectedObjectChanged];
    }
}


// --------------------------------------------------------------
- (void) TA_popUpButtonCellWillPopUp:(NSNotification *) notification
{
    // Register ourselves to receive a notification when the popup menu is
    // dismissed.
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(TA_menuDidEndTracking:)
                   name:NSMenuDidEndTrackingNotification
                 object:[self menu]];
    
    // Wipe the current contents of the popup button's menu and repopulate it
    // with elements from the data source.

    [self selectItem:nil];
    [self removeAllItems];
    
    int selectedIndex = 0;
    
    int count = [self TA_countOfChildrenOfProxyItem:nil];
    
    if(count == 0)
    {
        NSMenuItem *menuItem = [self TA_menuItemForNoContent];
        [[self menu] addItem:menuItem];

        selectedIndex = 0;
    }
    else
    {
        [self TA_addChildrenOfProxyItem:nil toMenu:[self menu]];
        
        if(objectValue)
        {
            selectedIndex =
            [self TA_indexOfProxyItemWithRepresentedObject:objectValue];
        }
        else
        {
            selectedIndex = -1;
        }
        
        if(selectedIndex < 0)
        {
            // If the currently selected object in the popup button is not in
            // the root menu, we add it as a special item at the top of the
            // menu, followed by a separator, so that the popup interface still
            // works as expected.
            
            NSMenuItem *menuItem;

            if(objectValue == nil)
                menuItem = [self TA_menuItemForNoSelection];
            else
                menuItem = [self TA_menuItemForObject:objectValue
                                       usingProxyItem:nil];

            [[self menu] insertItem:menuItem atIndex:0];

            // Only add a separator if the data source has root items.

            int count = [self TA_countOfChildrenOfProxyItem:nil];
            
            if(count > 0)
            {
                [[self menu] insertItem:[NSMenuItem separatorItem] atIndex:1];
            }
            
            selectedIndex = 0;
        }
    }
    
    [self selectItemAtIndex:selectedIndex];
}


// --------------------------------------------------------------
- (void) TA_menuDidEndTracking:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:NSMenuDidEndTrackingNotification
     object:[notification object]];
    
    // Send the TA_reset message to update the popup control to reflect the
    // item that was just selected.
    
    [self performSelector:@selector(TA_reset)
               withObject:nil
               afterDelay:0];
}


// --------------------------------------------------------------
- (void) TA_menuItemSelected:(id) sender
{
    // If the sender of the action was a menu item, obtain the newly selected
    // object from the menu item.
    
    if([sender isKindOfClass:[NSMenuItem class]])
    {
        id proxyItem = [sender representedObject];
        id newObject = [self TA_representedObjectForProxyItem:proxyItem];

        self.objectValue = newObject;
        [self TA_reset];
    }
    
    // If the selectedObject binding is connected, notify the observed object
    // that the selection has changed.
    
    [self TA_notifyObserverSelectedObjectChanged];

    // Send the original action that is connected to the popup button.
    
    [NSApp sendAction:[self action] to:[self target] from:sender];
}


// --------------------------------------------------------------
- (void) TA_addChildrenOfProxyItem:(id) parentItem toMenu:(NSMenu *) menu
{
    // This message recursively creates menu items and submenus for the items
    // in the data source that are children of the specified item.
    
    int count = [self TA_countOfChildrenOfProxyItem:parentItem];
    int i;
    
    for(i = 0; i < count; i++)
    {
        id proxyItem = [self TA_child:i ofProxyItem:parentItem];
        id item = [self TA_representedObjectForProxyItem:proxyItem];
        
        // If the data source returns a menu separator, we can add that to the
        // menu directly; otherwise, we create a new item with the appropriate
        // label and image.
        
        if(item == [NSNull null])
        {
            [menu addItem:[NSMenuItem separatorItem]];
        }
        else if([item isKindOfClass:[NSMenuItem class]])
        {
            [menu addItem:item];
        }
        else
        {
            NSMenuItem *menuItem = [self TA_menuItemForObject:item
                                               usingProxyItem:proxyItem];
            [menu addItem:menuItem];
            
            BOOL isExpandable =
            [self TA_countOfChildrenOfProxyItem:proxyItem] > 0;

            if(isExpandable)
            {
                NSMenu *subMenu = [[NSMenu alloc] init];

                TATreePopUpButtonSubMenuHelper *helper =
                [[TATreePopUpButtonSubMenuHelper alloc]
                 initWithOwningCell:self proxyItem:proxyItem];

                [subMenu setDelegate:helper];
                [menuItem setSubmenu:subMenu];
                [subMenu release];
            }
        }
    }
}


// --------------------------------------------------------------
- (NSMenuItem *) TA_menuItemForNoContent
{
    NSString *label;
    
    if(noContentPlaceholder)
        label = noContentPlaceholder;
    else
        label = @"";
    
    NSMenuItem *menuItem = [[NSMenuItem alloc]
                            initWithTitle:label
                            action:nil
                            keyEquivalent:@""];
    
    [menuItem setEnabled:NO];
    
    return menuItem;
}


// --------------------------------------------------------------
- (NSMenuItem *) TA_menuItemForNoSelection
{
    NSString *label;
    
    if(noSelectionPlaceholder)
        label = noSelectionPlaceholder;
    else
        label = @"";
    
    NSMenuItem *menuItem = [[NSMenuItem alloc]
                            initWithTitle:label
                            action:nil
                            keyEquivalent:@""];
    
    [menuItem setEnabled:YES];
    
    return menuItem;
}


// --------------------------------------------------------------
- (BOOL) TA_isContentBoundToTreeController
{
    NSDictionary *info = [self infoForBinding:NSContentBinding];
    if(!info)
    {
        info = [[self controlView] infoForBinding:NSContentBinding];
    }
    
    if(info)
    {
        id observedObject = [info objectForKey:NSObservedObjectKey];
        return [observedObject isKindOfClass:[NSTreeController class]];
    }
    else
    {
        return NO;
    }
}


// --------------------------------------------------------------
- (int) TA_countOfChildrenOfProxyItem:(id) proxyItem
{
    id content = [self TA_content];

    if(content)
    {
        if(proxyItem == nil)
        {
            return [content count];
        }
        else
        {
            if([self TA_isContentBoundToTreeController])
            {
                return [[proxyItem childNodes] count];
            }
            else
            {
                return 0;
            }
        }
    }
    else
    {
        id item = proxyItem;

        if(dataSource &&
           [dataSource respondsToSelector:
            @selector(treePopUpButtonCell:isItemExpandable:)])
        {
            BOOL expandable = [dataSource treePopUpButtonCell:self
                                             isItemExpandable:item];
            
            if(!expandable)
                return 0;
        }
        
        if([[self controlView] isKindOfClass:[TATreePopUpButton class]])
        {
            id control = (TATreePopUpButton *)[self controlView];
            id controlDataSource = [control dataSource];
            
            if(controlDataSource &&
               [controlDataSource respondsToSelector:
                @selector(treePopUpButton:isItemExpandable:)])
            {
                BOOL expandable = [controlDataSource treePopUpButton:control
                                                    isItemExpandable:item];
                
                if(!expandable)
                    return 0;
            }
        }
        
        if(dataSource &&
           [dataSource respondsToSelector:
            @selector(treePopUpButtonCell:numberOfChildrenOfItem:)])
        {
            return [dataSource treePopUpButtonCell:self
                            numberOfChildrenOfItem:item];
        }
        
        if([[self controlView] isKindOfClass:[TATreePopUpButton class]])
        {
            id control = (TATreePopUpButton *)[self controlView];
            id controlDataSource = [control dataSource];
            
            if(controlDataSource &&
               [controlDataSource respondsToSelector:
                @selector(treePopUpButton:numberOfChildrenOfItem:)])
            {
                return [controlDataSource treePopUpButton:control
                                   numberOfChildrenOfItem:item];
            }
        }
        
        return 0;
    }
}


// --------------------------------------------------------------
- (id) TA_child:(int) index ofProxyItem:(id) proxyItem
{
    id content = [self TA_content];

    if(content)
    {
        if(proxyItem == nil)
        {
            return [content objectAtIndex:index];
        }
        else
        {
            if([self TA_isContentBoundToTreeController])
            {
                return [[proxyItem childNodes] objectAtIndex:index];
            }
            else
            {
                return nil;
            }
        }
    }
    else
    {
        id item = proxyItem;

        if(dataSource &&
           [dataSource respondsToSelector:
            @selector(treePopUpButtonCell:child:ofItem:)])
        {
            return [dataSource treePopUpButtonCell:self
                                             child:index
                                            ofItem:item];
        }
        
        if([[self controlView] isKindOfClass:[TATreePopUpButton class]])
        {
            id control = (TATreePopUpButton *)[self controlView];
            id controlDataSource = [control dataSource];
            
            if(controlDataSource &&
               [controlDataSource respondsToSelector:
                @selector(treePopUpButton:child:ofItem:)])
            {
                return [controlDataSource treePopUpButton:control
                                                    child:index
                                                   ofItem:item];
            }
        }
        
        return nil;
    }   
}


// --------------------------------------------------------------
- (id) TA_representedObjectForProxyItem:(id) item
{
    id content = [self TA_content];

    if(content && [self TA_isContentBoundToTreeController])
    {
        return [item representedObject];
    }
    else
    {
        return item;
    }
}


// --------------------------------------------------------------
- (NSString *) TA_titleForItemFromDelegates:(id) item
{
    if(delegate && [delegate respondsToSelector:
                    @selector(treePopUpButtonCell:titleForItem:)])
    {
        return [delegate treePopUpButtonCell:self titleForItem:item];
    }

    if([[self controlView] isKindOfClass:[TATreePopUpButton class]])
    {
        id control = (TATreePopUpButton *)[self controlView];
        id controlDelegate = [control delegate];
        
        if(controlDelegate && [controlDelegate respondsToSelector:
                               @selector(treePopUpButton:titleForItem:)])
        {
            return [controlDelegate treePopUpButton:control titleForItem:item];
        }
    }
    
    return [item description];
}


// --------------------------------------------------------------
- (NSImage *) TA_imageForItemFromDelegates:(id) item
{
    if(delegate && [delegate respondsToSelector:
                    @selector(treePopUpButtonCell:imageForItem:)])
    {
        return [delegate treePopUpButtonCell:self imageForItem:item];
    }
    
    if([[self controlView] isKindOfClass:[TATreePopUpButton class]])
    {
        id control = (TATreePopUpButton *)[self controlView];
        id controlDelegate = [control delegate];
        
        if(controlDelegate && [controlDelegate respondsToSelector:
                               @selector(treePopUpButton:titleForItem:)])
        {
            return [controlDelegate treePopUpButton:control imageForItem:item];
        }
    }
    
    return nil;
}


// --------------------------------------------------------------
- (BOOL) TA_isItemEnabledFromDelegates:(id) item
{
    if(delegate && [delegate respondsToSelector:
                    @selector(treePopUpButtonCell:isItemEnabled:)])
    {
        return [delegate treePopUpButtonCell:self isItemEnabled:item];
    }
    
    if([[self controlView] isKindOfClass:[TATreePopUpButton class]])
    {
        id control = (TATreePopUpButton *)[self controlView];
        id controlDelegate = [control delegate];
        
        if(controlDelegate && [controlDelegate respondsToSelector:
                               @selector(treePopUpButton:isItemEnabled:)])
        {
            return [controlDelegate treePopUpButton:control isItemEnabled:item];
        }
    }
    
    return YES;
}


// --------------------------------------------------------------
- (int) TA_indexOfProxyItemWithRepresentedObject:(id) anObject
{
    int result = -1;

    int i;
    for(i = 0; i < [[self menu] numberOfItems]; i++)
    {
        NSMenuItem *menuItem = [[self menu] itemAtIndex:i];

        id proxyItem = [menuItem representedObject];
        
        if([self TA_isContentBoundToTreeController])
        {
            if(proxyItem && [proxyItem representedObject] == anObject)
            {
                result = i;
                break;
            }
        }
        else
        {
            if(proxyItem == anObject)
            {
                result = i;
                break;
            }
        }
    }
    
    return result;
}


// --------------------------------------------------------------
- (NSMenuItem *) TA_menuItemForObject:(id) anObject
                       usingProxyItem:(id) proxyItem
{
    NSString *label = [self TA_titleForItemFromDelegates:anObject];
    
    NSMenuItem *menuItem = [[NSMenuItem alloc]
                            initWithTitle:label
                            action:@selector(TA_menuItemSelected:)
                            keyEquivalent:@""];

    [menuItem setTarget:self];
    
    if(proxyItem == nil)
    {
        if([self TA_isContentBoundToTreeController])
        {
            proxyItem = [[TATreePopUpButtonFakeProxyItem alloc]
                         initWithRepresentedObject:anObject];
        }
        else
        {
            proxyItem = anObject;
        }
    }

    [menuItem setRepresentedObject:proxyItem];
    
    BOOL isEnabled = [self TA_isItemEnabledFromDelegates:anObject];
    [menuItem setEnabled:isEnabled];
    
    NSImage *image = [self TA_imageForItemFromDelegates:anObject];
    [menuItem setImage:image];

    return menuItem;
}

@end
