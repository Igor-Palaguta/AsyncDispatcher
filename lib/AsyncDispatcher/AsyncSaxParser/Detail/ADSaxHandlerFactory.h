#import <AsyncDispatcher/Detail/ADExport.h>

#include <libxml/SAX.h>

@protocol ADSaxHandler;

AD_EXPORT xmlSAXHandlerPtr ADCreateLibXmlSaxHandler();
