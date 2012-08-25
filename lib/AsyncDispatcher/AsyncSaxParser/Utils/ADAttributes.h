#import "../ADXmlDefs.h"

#import <Foundation/Foundation.h>

typedef BOOL (^ADAttributeHandler)( NSString* name_, NSString* value_ );
typedef BOOL (^ADAttributeFastHandler)( const ADXMLChar* name_, const ADXMLChar* value_ );

/** Wrapper around attributes, that ADSaxHandler passes to [ADSaxHandler didStartElementWithName:attributes:]
 */
@interface ADAttributes : NSObject

/** Returns ADAttributes instance
 @param attributes_ ADSaxHandler attributes
 */
-(id)initWithAttributes:( const ADXMLChar** )attributes_;

/** Iterates through each attribute, or until handler_ block returns NO. Converts every attribute's name and value to NSString and calls handler_ block
 @param handler_ Handler block
 */


-(BOOL)each:( ADAttributeHandler )handler_;

/** Iterates through each attribute, or until handler_ block returns NO. For every attribute's name and value calls handler_ block
 @param handler_ Handler block
 */
-(BOOL)fastEach:( ADAttributeFastHandler )handler_;

@end

/** Category for conversion const ADXMLChar** to NSDictionary
 */
@interface NSDictionary (ADAttributes)

/** Returns NSDictionary instance. Key of dictionary is attribute name
 @param attributes_ ADSaxHandler attributes
 */
+(id)dictionaryWithAttributes:( const ADXMLChar** )attributes_;

@end
