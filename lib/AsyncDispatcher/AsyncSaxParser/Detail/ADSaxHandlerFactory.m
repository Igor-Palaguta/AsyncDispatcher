#import "ADSaxHandlerFactory.h"

#import "ADSaxHandler.h"

static void	start_element( void* context_
                          , const xmlChar* name_
                          , const xmlChar** attributes_ )
{
   id< ADSaxHandler > handler_ = ( __bridge id< ADSaxHandler > )context_;
   [ handler_ didStartElementWithName: name_
                           attributes: attributes_ ];
}

static void	end_element( void* context_
                        , const xmlChar* name_ )
{
   id< ADSaxHandler > handler_ = ( __bridge id< ADSaxHandler > )context_;
   [ handler_ didEndElementWithName: name_ ];
}

static void character( void* context_
                      , const xmlChar* characters_
                      , int length_)
{
   id< ADSaxHandler > handler_ = ( __bridge id< ADSaxHandler > )context_;
   [ handler_ didFoundCharacters: characters_
                      withLength: length_ ];
}

static void start_document( void* context_ )
{
   id< ADSaxHandler > handler_ = ( __bridge id< ADSaxHandler > )context_;
   [ handler_ didStartDocument ];
}

static void end_document( void* context_ )
{
   id< ADSaxHandler > handler_ = ( __bridge id< ADSaxHandler > )context_;
   [ handler_ didEndDocument ];
}

xmlSAXHandlerPtr ADCreateLibXmlSaxHandler()
{
   xmlSAXHandlerPtr sax_handler_ = (xmlSAXHandlerPtr)malloc( sizeof( xmlSAXHandler ) );
   memset( sax_handler_, 0, sizeof(xmlSAXHandler) );

   sax_handler_->initialized = XML_SAX2_MAGIC;
   sax_handler_->startElement = start_element;
   sax_handler_->endElement = end_element;
   sax_handler_->characters = character;
   sax_handler_->startDocument = start_document;
   sax_handler_->endDocument = end_document;
   return sax_handler_;
}