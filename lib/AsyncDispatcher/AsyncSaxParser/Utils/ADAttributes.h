#import "../ADXmlDefs.h"

#import <Foundation/Foundation.h>

typedef BOOL (^ADAttributeHandler)( NSString* name_, NSString* value_ );
typedef BOOL (^ADAttributeFastHandler)( const ADXMLChar* name_, const ADXMLChar* value_ );

@interface ADAttributes : NSObject

-(id)initWithAttributes:( const ADXMLChar** )attributes_;

-(BOOL)each:( ADAttributeHandler )handler_;
-(BOOL)fastEach:( ADAttributeFastHandler )handler_;

@end

@interface NSDictionary (ADAttributes)

+(id)dictionaryWithAttributes:( const ADXMLChar** )attributes_;

@end
