#import <Foundation/Foundation.h>

#include <libxml/xmlerror.h>

extern NSString* const ADLibXmlErrorDomain;

@interface NSError (LibXml)

+(id)errorWithLibXmlErrno:( int )errno_;
+(id)errorWithLibXmlLastError;
+(id)errorWithLibXmlError:( xmlErrorPtr )error_;

@end
