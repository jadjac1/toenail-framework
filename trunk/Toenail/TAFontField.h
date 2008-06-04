// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TAFontField.h
//
//  Summary:   Declaration of the TAFontField class.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import <Cocoa/Cocoa.h>

// ============================================================================

/*!
 
 @class TAFontField
 
 @abstract A TAFontField is a control that displays the name and point size of
 a font, previewed in the font itself. It also provides an action that
 completely managed the selection of a new font and text attributes from the
 system font panel.

 */
@interface TAFontField : NSView
{
    // Property-backed instance variables
    id delegate;
    NSFont *selectedFont;
    NSFontDescriptor *selectedFontDescriptor;
    NSDictionary *selectedAttributes;

    // Cocoa bindings support
    id observedObjectForSelectedFont;
    NSString *observedKeyPathForSelectedFont;
    id observedObjectForSelectedFontDescriptor;
    NSString *observedKeyPathForSelectedFontDescriptor;
    id observedObjectForSelectedAttributes;
    NSString *observedKeyPathForSelectedAttributes;

    // Other ivars
    NSTextField *nestedField;
}


// Properties .................................................................

/*!
 
 @property delegate
 
 @abstract An object that implements the TAFontFieldDelegate protocol.
 The delegate is not retained.
 
 */
@property (assign, nonatomic) id delegate;


/*!
 
 @property selectedFont
 
 @abstract The currently selected font.
 
 */
@property (copy, nonatomic) NSFont *selectedFont;


/*!
 
 @property selectedFontDescriptor
 
 @abstract A pointer to an NSFontDescriptor that describes the currently
 selected font.
 
 */
@property (copy, nonatomic) NSFontDescriptor *selectedFontDescriptor;


/*!
 
 @property selectedAttributes
 
 @abstract A pointer to an NSDictionary that contains any additional text
 attributes chosen in the font panel.
 
 */
@property (copy, nonatomic) NSDictionary *selectedAttributes;


@property (retain, nonatomic) id observedObjectForSelectedFont;
@property (copy, nonatomic) NSString *observedKeyPathForSelectedFont;
@property (retain, nonatomic) id observedObjectForSelectedFontDescriptor;
@property (copy, nonatomic) NSString *observedKeyPathForSelectedFontDescriptor;
@property (retain, nonatomic) id observedObjectForSelectedAttributes;
@property (copy, nonatomic) NSString *observedKeyPathForSelectedAttributes;


// Methods ....................................................................

/*!

 @method chooseFont:
 
 @abstract An action to choose a font for the font field. A button or other
 control can be connected to this action in Interface Builder to pop up the
 font panel.

 */
- (IBAction)chooseFont:(id)sender;


@end



// ============================================================================

/*!
 
 @protocol TAFontFieldDelegate
 
 @abstract The TAFontFieldDelegate informal protocol should be implemented by
 classes that will act as a delegate for a TAFontField control.
 
 */
@interface NSObject (TAFontFieldDelegate)

/*!
 
 @method fontField:didChangeFont:
 
 @abstract Called when the user selects a new font from the font panel.
 
 @param sender the font field
 @param font the new font

 */
- (void) fontField:(id)sender didChangeFont:(NSFont *)font;


/*!
 
 @method fontField:didChangeAttributes:
 
 @abstract Called when the user makes a selection in the font panel that
 changes the current text attributes.
 
 @param sender the font field
 @param attributes the new text attributes
 
 */
- (void) fontField:(id)sender didChangeAttributes:(NSDictionary *)attributes;

@end

