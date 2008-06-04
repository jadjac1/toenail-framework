// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TAFontFieldInspector.h
//
//  Summary:   Declaration of the TAFontFieldInspector class, the IB inspector
//             for the TAFontField control.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>

// ============================================================================

@interface TAFontFieldInspector : IBInspector
{
}

// Methods ....................................................................

/*!
 
 @method chooseFont:
 
 @abstract An action that lets the user choose the font for the font field from
 the system font panel.
 
 @param sender the sender of the action
 
 */
- (IBAction) chooseFont: (id)sender;

@end
