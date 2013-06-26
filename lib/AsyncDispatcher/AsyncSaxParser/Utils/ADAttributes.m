#import "ADAttributes.h"

@interface ADAttributes ()

@property ( nonatomic, assign ) const ADXMLChar** attributes;

@end

@implementation ADAttributes

@synthesize attributes;

-(id)initWithAttributes:( const ADXMLChar** )attributes_
{
   self = [ super init ];
   if ( self )
   {
      self.attributes = attributes_;
   }
   return self;
}

-(BOOL)each:( ADAttributeHandler )handler_
{
   return [ self fastEach: ^BOOL( const ADXMLChar* name_, const ADXMLChar* value_ )
           {
              NSString* name_str_ = @(( const char* )name_);
              NSString* value_str_ = @(( const char* )value_);

              return handler_( name_str_, value_str_ );
           }];
}

-(BOOL)fastEach:( ADAttributeFastHandler )handler_
{
   BOOL continue_ = YES;
   for ( const ADXMLChar** current_attribute_ = self.attributes; continue_ && *current_attribute_; )
   {
      const ADXMLChar* name_ = *current_attribute_++;
      const ADXMLChar* value_ = *current_attribute_++;
      continue_ = handler_( name_, value_ );
   }
   return continue_;
}

@end

@implementation NSDictionary (ADAttributes)

+(id)dictionaryWithAttributes:( const ADXMLChar** )attributes_
{
   ADAttributes* proxy_attributes_ = [ [ ADAttributes alloc ] initWithAttributes: attributes_ ];

   NSMutableDictionary* dictionary_ = [ NSMutableDictionary dictionary ];
   [ proxy_attributes_ each: ^BOOL( NSString* name_, NSString* value_ )
    {
       [ dictionary_ setObject: value_ forKey: name_ ];
       return YES;
    }];
   return dictionary_;
}

@end

