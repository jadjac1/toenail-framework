// ============================================================================
//  $Id$
// ============================================================================
//
//  File:      TAFontField.m
//
//  Summary:   Implementation of the TAFontField class.
//
//  Author:    Tony Allevato
//
// ============================================================================

#import "TAFontField.h"

// ============================================================================

@interface TAFontField (Private)

- (void) _initDefaults;
- (void) _updateLabel;

- (void) changeFieldFont:(id)sender;
- (void) changeAttributes:(id)sender;

@end

// ============================================================================

// Binding observation context tokens

static void *SelectedFontObsCtx = (void *)1091;
static void *SelectedFontDescriptorObsCtx = (void *)1092;
static void *SelectedAttributesObsCtx = (void *)1093;

@implementation TAFontField


// --------------------------------------------------------------

// Property synthesizers

@synthesize delegate;
@synthesize selectedFont;
@synthesize selectedFontDescriptor;
@synthesize selectedAttributes;
@synthesize observedObjectForSelectedFont;
@synthesize observedKeyPathForSelectedFont;
@synthesize observedObjectForSelectedFontDescriptor;
@synthesize observedKeyPathForSelectedFontDescriptor;
@synthesize observedObjectForSelectedAttributes;
@synthesize observedKeyPathForSelectedAttributes;


// --------------------------------------------------------------
+ (void) initialize
{
    [self exposeBinding:@"selectedFont"];
    [self exposeBinding:@"selectedFontDescriptor"];
    [self exposeBinding:@"selectedAttributes"];
}


// --------------------------------------------------------------
+ (NSArray *) exposedBindings
{
    return [NSArray arrayWithObjects:
            @"selectedFont",
            @"selectedFontDescriptor",
            @"selectedAttributes",
            nil];
}


// --------------------------------------------------------------
- (Class) valueClassForBinding:(NSString *)binding
{
    if([binding isEqualToString:@"selectedFont"])
        return [NSFont class];
    else if([binding isEqualToString:@"selectedFontDescriptor"])
        return [NSFontDescriptor class];
    else if([binding isEqualToString:@"selectedAttributes"])
        return [NSDictionary class];
    else
        return [super valueClassForBinding:binding];
}


// --------------------------------------------------------------
- (void) bind:(NSString *)bindingName
     toObject:(id)observableController
  withKeyPath:(NSString *)keyPath
      options:(NSDictionary *)options
{   
    if([bindingName isEqualToString:@"selectedFont"])
    {
        [observableController addObserver:self
                               forKeyPath:keyPath 
                                  options:0
                                  context:SelectedFontObsCtx];
        
        [self setObservedObjectForSelectedFont:observableController];
        [self setObservedKeyPathForSelectedFont:keyPath];
    }
    else if([bindingName isEqualToString:@"selectedFontDescriptor"])
    {
        [observableController addObserver:self
                               forKeyPath:keyPath 
                                  options:0
                                  context:SelectedFontDescriptorObsCtx];
        
        [self setObservedObjectForSelectedFontDescriptor:observableController];
        [self setObservedKeyPathForSelectedFontDescriptor:keyPath];
    }
    else if([bindingName isEqualToString:@"selectedAttributes"])
    {
        [observableController addObserver:self
                               forKeyPath:keyPath 
                                  options:0
                                  context:SelectedAttributesObsCtx];
        
        [self setObservedObjectForSelectedAttributes:observableController];
        [self setObservedKeyPathForSelectedAttributes:keyPath];
    }
    
    [super bind:bindingName
       toObject:observableController
    withKeyPath:keyPath
        options:options];

    // Update the contents of the field when the bindings have changed.
    
    [self _updateLabel];
}


// --------------------------------------------------------------
- (void) unbind:(NSString *)bindingName
{
    if([bindingName isEqualToString:@"selectedFont"])
    {
        [observedObjectForSelectedFont
         removeObserver:self
         forKeyPath:observedKeyPathForSelectedFont];
        
        [self setObservedObjectForSelectedFont:nil];
        [self setObservedKeyPathForSelectedFont:nil];
    }   
    else if([bindingName isEqualToString:@"selectedFontDescriptor"])
    {
        [observedObjectForSelectedFontDescriptor
         removeObserver:self
         forKeyPath:observedKeyPathForSelectedFontDescriptor];

        [self setObservedObjectForSelectedFontDescriptor:nil];
        [self setObservedKeyPathForSelectedFontDescriptor:nil];
    }
    else if([bindingName isEqualToString:@"selectedAttributes"])
    {
        [observedObjectForSelectedAttributes
         removeObserver:self
         forKeyPath:observedKeyPathForSelectedAttributes];

        [self setObservedObjectForSelectedAttributes:nil];
        [self setObservedKeyPathForSelectedAttributes:nil];
    }   
    
    [super unbind:bindingName];
    
    // Update the contents of the field when the bindings have changed.

    [self _updateLabel];
}


// --------------------------------------------------------------
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if(context == SelectedFontObsCtx)
    {
        id newFont = [observedObjectForSelectedFont
                      valueForKeyPath:observedKeyPathForSelectedFont];

        [self setValue:newFont forKey:@"selectedFont"];
    }
    else if(context == SelectedFontDescriptorObsCtx)
    {
        id newFontDescriptor = [observedObjectForSelectedFontDescriptor
                                valueForKeyPath:
                                observedKeyPathForSelectedFontDescriptor];

        [self setValue:newFontDescriptor forKey:@"selectedFontDescriptor"];
    }
    else if(context == SelectedAttributesObsCtx)
    {
        id newAttributes = [observedObjectForSelectedAttributes
                            valueForKeyPath:
                            observedKeyPathForSelectedAttributes];

        [self setValue:newAttributes forKey:@"selectedAttributes"];
    }
    
    // Update the contents of the field when the bindings have changed.

    [self _updateLabel];
}


// --------------------------------------------------------------
- (id) initWithFrame: (NSRect)frameRect
{
    if(self = [super initWithFrame:frameRect])
    {
        // Create the nested text field that will display the text for the
        // currently selected font.
        
        NSRect nestedRect = NSMakeRect(0, 0,
                                       NSWidth(frameRect),
                                       NSHeight(frameRect));
        
        nestedField = [[NSTextField alloc] initWithFrame:nestedRect];
        [nestedField setEditable:NO];
        [nestedField setSelectable:NO];
        [nestedField setAlignment:NSCenterTextAlignment];
        [nestedField setAutoresizingMask:
         (NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin)];
        
        [self addSubview:nestedField];
        
        [self _initDefaults];
    }
    
    return self;
}


// --------------------------------------------------------------
- (id) initWithCoder: (NSCoder *)coder
{
    if(self = [super initWithCoder:coder])
    {
        if([coder respondsToSelector:@selector(allowsKeyedCoding)] &&
           [coder allowsKeyedCoding])
        {
            nestedField = [coder decodeObjectForKey:@"nestedField"];
            
            [self setSelectedFontDescriptor:
             [coder decodeObjectForKey:@"selectedFontDescriptor"]];
            [self setSelectedAttributes:
             [coder decodeObjectForKey:@"selectedAttributes"]];
        }
        else
        {
            nestedField = [coder decodeObject];
            
            [self setSelectedFontDescriptor:[coder decodeObject]];
            [self setSelectedAttributes:[coder decodeObject]];
        }
        
        [self _initDefaults];
    }
    
    return self;    
}


// --------------------------------------------------------------
- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    if([coder respondsToSelector:@selector(allowsKeyedCoding)] &&
       [coder allowsKeyedCoding])
    {
        [coder encodeObject:nestedField forKey:@"nestedField"];
        
        [coder encodeObject:selectedFontDescriptor
                     forKey:@"selectedFontDescriptor"];
        
        [coder encodeObject:selectedAttributes
                     forKey:@"selectedAttributes"];
    }
    else
    {
        [coder encodeObject:nestedField];
        [coder encodeObject:selectedFontDescriptor];
        [coder encodeObject:selectedAttributes];
    }
}


// --------------------------------------------------------------
- (void) setSelectedFont:(NSFont *)aFont
{
    if(aFont != selectedFont)
    {
        // Keep the font and font descriptors in synch.
        
        [selectedFont release];
        selectedFont = [aFont copy];
        [[NSFontManager sharedFontManager] setSelectedFont:selectedFont
                                                isMultiple:NO];
        
        [selectedFontDescriptor release];
        selectedFontDescriptor = [[selectedFont fontDescriptor] copy];
        
        // Update the label when the font changes.
        
        [self _updateLabel];
    }
}


// --------------------------------------------------------------
- (void) setSelectedFontDescriptor:(NSFontDescriptor *)aFontDescriptor
{
    if(aFontDescriptor != selectedFontDescriptor)
    {
        // Keep the font and font descriptors in synch.

        [selectedFontDescriptor release];
        selectedFontDescriptor = [aFontDescriptor copy];
        
        CGFloat pointSize = [selectedFontDescriptor pointSize];
        
        selectedFont = [[NSFont fontWithDescriptor:selectedFontDescriptor
                                              size:pointSize] copy];
        
        [[NSFontManager sharedFontManager] setSelectedFont:selectedFont
                                                isMultiple:NO];

        // Update the label when the selected font descriptor changes.

        [self _updateLabel];
    }
}


// --------------------------------------------------------------
- (void) setSelectedAttributes:(NSDictionary *)anAttributes
{
    if(anAttributes != selectedAttributes)
    {
        [selectedAttributes release];
        selectedAttributes = [anAttributes copy];

        [[NSFontManager sharedFontManager]
         setSelectedAttributes:selectedAttributes isMultiple:NO];
    
        // Update the label when the selected text attributes change.

        [self _updateLabel];
    }
}


// --------------------------------------------------------------
- (IBAction) chooseFont:(id)sender
{
    // Order the system font panel to the front and make this field the first
    // responder so that change notifications get sent to it.

    [[self window] makeFirstResponder:self];

    NSFontManager *manager = [NSFontManager sharedFontManager];
    
    [manager setSelectedFont:selectedFont isMultiple:NO];
    [manager setSelectedAttributes:selectedAttributes isMultiple:NO];
    [manager setDelegate:self];
    [manager setAction:@selector(changeFieldFont:)];
    [manager orderFrontFontPanel:self];
}


// --------------------------------------------------------------
- (BOOL) acceptsFirstResponder
{
    return YES;
}

@end


// ============================================================================


@implementation TAFontField (Private)

// --------------------------------------------------------------
- (void) _initDefaults
{
    if(selectedFontDescriptor == nil)
    {
        NSDictionary *fontAttributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
         @"Helvetica", NSFontNameAttribute, nil];
        
        selectedFontDescriptor = [[NSFontDescriptor alloc]
                                  initWithFontAttributes:fontAttributes];
        
        selectedFont = [NSFont fontWithDescriptor:selectedFontDescriptor
                                             size:12];
    }
    
    if(selectedAttributes == nil)
    {
        selectedAttributes = [[NSDictionary alloc] init];
    }
    
    [self _updateLabel];
}


// --------------------------------------------------------------
- (void) _updateLabel
{
    if(selectedFont == nil)
    {
        [nestedField setStringValue:@""];
        return;
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    NSFont* displayFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    
    [attributes setObject:displayFont forKey:NSFontAttributeName];
    [attributes setObject:style forKey:NSParagraphStyleAttributeName];
    
    NSString *label = [NSString stringWithFormat:@"%@ %d",
                       [selectedFont displayName],
                       (int)[selectedFont pointSize]];
    
    NSAttributedString *string =
    [[NSAttributedString alloc] initWithString:label
                                    attributes:attributes];
    
    [nestedField setFont:selectedFont];
    [nestedField setStringValue:label];
    
    float originalWidth = NSWidth([self frame]);
    float originalHeight = NSHeight([self frame]);
    [nestedField sizeToFit];
    float nestedHeight = NSHeight([nestedField bounds]);
    
    NSRect frame = [nestedField frame];
    frame.origin.x = 0;
    frame.origin.y = (originalHeight - nestedHeight) / 2;
    frame.size.width = originalWidth;
    [nestedField setFrame:frame];
    
    [string release];
    [style release];
}


// --------------------------------------------------------------
- (void) changeFieldFont:(id)sender
{
    NSFont *newFont = [sender convertFont:selectedFont];
    if(newFont != selectedFont)
    {
        [selectedFont release];
        selectedFont = [newFont retain];
    }
    
    [selectedFontDescriptor release];
    selectedFontDescriptor = [[selectedFont fontDescriptor] retain];
    
    if(observedObjectForSelectedFont)
    {
        [observedObjectForSelectedFont
         setValue:selectedFont
         forKeyPath:observedKeyPathForSelectedFont];
    }
    
    if(observedObjectForSelectedFontDescriptor)
    {
        [observedObjectForSelectedFontDescriptor
         setValue:selectedFontDescriptor
         forKeyPath:observedKeyPathForSelectedFontDescriptor];
    }
    
    if([self delegate] &&
       [[self delegate] respondsToSelector:@selector(fontField:didChangeFont:)])
    {
        [[self delegate] fontField:self didChangeFont:selectedFont];
    }
    
    [self _updateLabel];
}


// --------------------------------------------------------------
- (void) changeAttributes:(id)sender
{
    NSDictionary *newAttributes = [sender convertAttributes:selectedAttributes];
    
    if(newAttributes != selectedAttributes)
    {
        [selectedAttributes release];
        selectedAttributes = [newAttributes copy];
    }
    
    if(observedObjectForSelectedAttributes)
    {
        [observedObjectForSelectedAttributes
         setValue:selectedAttributes
         forKeyPath:observedKeyPathForSelectedAttributes];
    }
    
    if([self delegate] &&
       [[self delegate]
        respondsToSelector:@selector(fontField:didChangeAttributes:)])
    {
        [[self delegate] fontField:self didChangeAttributes:selectedAttributes];
    }
    
    [self _updateLabel];
}

@end
