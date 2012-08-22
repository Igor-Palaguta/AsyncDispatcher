#import <Foundation/Foundation.h>

#include <libxml/xmlerror.h>

extern NSString* const ADLibXmlErrorDomain;

typedef enum
{
   ADLibXmlSaxParserError = 1000
} ADLibXmlErrorType;

@interface NSError (LibXml)

+(id)errorWithLibXmlFormat:( const char* )format_
                 arguments:( va_list )arguments_;

+(id)errorWithLibXmlErrno:( int )errno_;
+(id)errorWithLibXmlLastError;
+(id)errorWithLibXmlError:( xmlErrorPtr )error_;

@end
