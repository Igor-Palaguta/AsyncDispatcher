#import "NSError+LibXml.h"

NSString* const ADLibXmlErrorDomain = @"com.AsyncSaxParser.libxml2";

@implementation NSError (LibXml)

+(id)parserErrorWithCode:( int )code_
             description:( NSString* )description_
{
   return [ self errorWithDomain: ADLibXmlErrorDomain
                            code: code_
                        userInfo: [ NSDictionary dictionaryWithObject: description_
                                                               forKey: NSLocalizedDescriptionKey ] ];
}

+(id)errorWithLibXmlErrno:( int )errno_
{
   if ( errno_ == XML_ERR_OK )
      return nil;

   const char* error_c_str_ = 0/*strerror( errno_ )*/;
   NSString* error_str_ = error_c_str_
      ? [ NSString stringWithUTF8String: error_c_str_ ]
      : [ NSString stringWithFormat: @"Error number: %d", errno_ ];

   return [ self parserErrorWithCode: errno_
                         description: error_str_ ];
}

+(id)errorWithLibXmlError:( xmlErrorPtr )error_
{
   return [ self parserErrorWithCode: error_->code
                         description: [ NSString stringWithUTF8String: error_->message ] ];
}

+(id)errorWithLibXmlLastError
{
   xmlErrorPtr	last_error_ = xmlGetLastError();
   if ( !last_error_ )
      return nil;

   xmlResetLastError();

   return [ self errorWithLibXmlError: last_error_ ];
}

@end
