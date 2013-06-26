#import "NSError+LibXml.h"

NSString* const ADLibXmlErrorDomain = @"com.AsyncSaxParser.libxml2";

@implementation NSError (LibXml)

+(id)libXmlErrorWithCode:( int )errno_
             description:( NSString* )error_str_
{
   return [ self errorWithDomain: ADLibXmlErrorDomain
                            code: errno_
                        userInfo: @{NSLocalizedDescriptionKey: error_str_} ];
}

+(id)libXmlErrorWithCode:( int )errno_
            cDescription:( const char* )error_c_str_
{
   NSString* error_str_ = error_c_str_
      ? @(error_c_str_)
      : [ NSString stringWithFormat: @"Error number: %d", errno_ ];

   return [ self libXmlErrorWithCode: errno_
                         description: error_str_ ];
}

+(id)errorWithLibXmlFormat:( const char* )format_
                 arguments:( va_list )arguments_
{
   NSString* format_str_ = @(format_);
   NSString* error_str_ = [ [ NSString alloc ] initWithFormat: format_str_
                                                    arguments: arguments_ ];

   return [ self libXmlErrorWithCode: ADLibXmlSaxParserError
                         description: error_str_ ];
}

+(id)errorWithLibXmlErrno:( int )errno_
{
   if ( errno_ == XML_ERR_OK )
      return nil;

   return [ self libXmlErrorWithCode: errno_ cDescription: 0 ];
}

+(id)errorWithLibXmlError:( xmlErrorPtr )error_
{
   return [ self libXmlErrorWithCode: error_->code cDescription: error_->message ];
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
