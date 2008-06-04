// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TATreePopUpButton+SharedPrivate.h
//
//  Summary:   Internal methods for the TATreePopUpButton class that need to be
//             accessible both to the button and cell classes, but not publicly
//             visible.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import "TATreePopUpButton.h"

// ============================================================================

@interface TATreePopUpButton (SharedPrivate)

- (void) TA_notifyObserverSelectedObjectChanged;

@end
