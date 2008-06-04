// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TATreePopUpButton.m
//
//  Summary:   Implementation of the TATreePopUpButton class.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import "TATreePopUpButton.h"
#import "TATreePopUpButton+SharedPrivate.h"
#import "TATreePopUpButtonCell.h"
#import "TATreePopUpButtonCell+SharedPrivate.h"

// ============================================================================

static void *ContentObsCtx = (void *)0x1001;
static void *SelectedObjectObsCtx = (void *)0x1002;

// ============================================================================

@implementation TATreePopUpButton

// --------------------------------------------------------------

// Property synthesizers

@synthesize delegate;
@synthesize dataSource;


// --------------------------------------------------------------
+ (Class) cellClass
{
    return [TATreePopUpButtonCell class];
}


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
        [[self cell] TA_reset];
    }
    else if(context == SelectedObjectObsCtx)
    {
        [self setObjectValue:newValue];
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
- (void) dealloc
{
    [self unbind:NSContentBinding];
    [self unbind:NSSelectedObjectBinding];

    delegate = nil;
    dataSource = nil;

    [super dealloc];
}


// --------------------------------------------------------------
- (void) setDelegate:(id) aDelegate
{
    delegate = aDelegate;

    [[self cell] TA_reset];
}


// --------------------------------------------------------------
- (void) setDataSource:(id) aDataSource
{
    dataSource = aDataSource;
    
    [[self cell] TA_reset];
}


// --------------------------------------------------------------
- (NSString *) noSelectionPlaceholder
{
    return [[self cell] noSelectionPlaceholder];
}


// --------------------------------------------------------------
- (void) setNoSelectionPlaceholder:(NSString *) aPlaceholder
{
    [[self cell] setNoSelectionPlaceholder:aPlaceholder];
}


// --------------------------------------------------------------
- (NSString *) noContentPlaceholder
{
    return [[self cell] noContentPlaceholder];
}


// --------------------------------------------------------------
- (void) setNoContentPlaceholder:(NSString *) aPlaceholder
{
    [[self cell] setNoContentPlaceholder:aPlaceholder];
}


// --------------------------------------------------------------
- (id) objectValue
{
    return [[self cell] objectValue];
}


// --------------------------------------------------------------
- (void) setObjectValue:(id) anObject
{
    [[self cell] setObjectValue:anObject];
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
            id selectedObject = [[self cell] objectValue];
            id oldValue = [object valueForKeyPath:keyPath];
            
            if(oldValue != selectedObject)
            {
                [object setValue:selectedObject
                      forKeyPath:keyPath];
            }
        }
    }
}


// --------------------------------------------------------------
- (void) viewDidMoveToSuperview
{
    [[self cell] TA_reset];
}

@end
