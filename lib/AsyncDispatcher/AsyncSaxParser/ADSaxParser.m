#import "ADSaxParser.h"

#import "ADSaxHandler.h"

#import "Detail/ADSaxHandlerFactory.h"
#import "Detail/NSError+LibXml.h"

#import <AsyncDispatcher/ADFileStream.h>
#import <AsyncDispatcher/ADBuffer.h>

#include <libxml/SAX.h>

@interface ADSaxParser ()

@property ( nonatomic, assign ) xmlParserCtxtPtr parserContext;
@property ( nonatomic, assign ) xmlSAXHandlerPtr saxHandler;
@property ( assign, getter=isCancelled ) BOOL cancelled;

-(void)parseStream:( id< ADStream > )stream_
           handler:( id< ADSaxHandler > )handler_
              name:( NSString* )name_;

@end

@implementation ADSaxParser

@synthesize parserContext = _parser_context;
@synthesize saxHandler = _sax_handler;
@synthesize cancelled;

-(void)dealloc
{
   if ( _parser_context )
   {
      xmlFreeParserCtxt( _parser_context );
   }
   
   if ( _sax_handler )
   {
      free( _sax_handler );
   }
}

-(xmlSAXHandlerPtr)saxHandler
{
   if ( !_sax_handler )
   {
      _sax_handler = ADCreateLibXmlSaxHandler();
   }
   return _sax_handler;
}

-(id)initWithStream:( id< ADStream > )stream_
            handler:( id< ADSaxHandler > )sax_handler_
               name:( NSString* )name_
{
   self = [ super init ];

   if ( self )
   {
      [ self parseStream: stream_ handler: sax_handler_ name: name_ ];
   }

   return self;
}

-(id)initWithStream:( id< ADStream > )stream_
            handler:( id< ADSaxHandler > )sax_handler_
{
   return [ self initWithStream: stream_
                        handler: sax_handler_
                           name: nil ];
}

-(id)initWithContentsOfFile:( NSString* )path_
                    handler:( id< ADSaxHandler > )handler_
{
   ADFileStream* stream_ = [ [ ADFileStream alloc ] initWithPath: path_ ];
   if ( !stream_ )
      return nil;

   return [ self initWithStream: stream_
                        handler: handler_
                           name: path_ ];
}

-(BOOL)parseBuffer:( id< ADBuffer > )buffer_
             error:( NSError** )error_
{
   NSAssert( error_, @"Error can't be null pointer" );
   
   __block NSError* local_error_ = nil;
   [ buffer_ eachChunk: ^BOOL( const void* data_, NSUInteger size_ )
    {
       int result_ = xmlParseChunk( self.parserContext
                                   , data_
                                   , size_
                                   , 0 );
       
       if ( result_ != XML_ERR_OK )
       {
          local_error_ = [ NSError errorWithLibXmlErrno: result_ ];
          return NO;
       }
       
       return YES;
    }];
   
   if ( local_error_ )
   {
      *error_ = local_error_;
      return NO;
   }
   
   return YES;
}

-(void)endParse
{
   xmlParseChunk( self.parserContext, 0, 0, 1 );
}

-(void)cancel
{
   self.cancelled = YES;
}

-(void)parseStream:( id< ADStream > )stream_
           handler:( id< ADSaxHandler > )handler_
              name:( NSString* )name_
{
   NSUInteger header_length_ = 4;
   NSUInteger buffer_length_ = 1024;
   
   [ stream_ read: header_length_
          handler: ^BOOL( BOOL eof_, id< ADBuffer > header_, NSError* error_ )
    {
       if ( error_ )
       {
          [ handler_ didFailWithError: error_ ];
          return NO;
       }
       else if ( eof_ )
       {
          [ handler_ didComplete ];
          return NO;
       }
       
       NSData* header_data_ = [ header_ data ];
       self.parserContext = xmlCreatePushParserCtxt
       ( self.saxHandler
        , ( __bridge void* )handler_
        , [ header_data_ bytes ]
        , [ header_data_ length ]
        , [ name_ UTF8String ]
        );

       if ( !self.parserContext )
       {
          [ handler_ didFailWithError: [ NSError errorWithLibXmlLastError ] ];
          return NO;
       }

       [ stream_ cyclicRead: buffer_length_
                    handler: ^BOOL( BOOL eof_, id< ADBuffer > buffer_, NSError* error_ )
        {
           if ( self.isCancelled )
              return NO;

           if ( error_ )
           {
              [ handler_ didFailWithError: error_ ];
              return NO;
           }

           NSError* parse_error_ = nil;
           if ( ![ self parseBuffer: buffer_ error: &parse_error_ ] )
           {
              //Sax Handler will notify about parse error
              //[ handler_ didFailWithError: parse_error_ ];
              return NO;
           }

           if ( eof_ )
           {
              [ handler_ didComplete ];
              [ self endParse ];
              return NO;
           }

           return !self.isCancelled;
        }];

       return YES;
    }];
}

@end
