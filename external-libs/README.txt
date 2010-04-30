## redneck
## -- needs redneck @ http://www.ialmeida.com/projects/redneck @ revision 662
## -- needs br.com.stimuli.BulkLoader @ http://bulk-loader.googlecode.com/svn/trunk/src/br/com/stimuli/loading @ revision 319
## -- needs br.com.stimuli.string @ http://printf-as3.googlecode.com/svn/trunk/src/br/com/stimuli/string @ revision 20
## -- needs com.adobe.serialization.JSON @ http://as3corelib.googlecode.com/svn/trunk/src/com/adobe/serialization/json @ revision 113
FLEX_COMPC -sp SOURCE_PATH -is SOURCE_PATH/redneck/ -o redneck.swc## Redneck

## com.adobe ## sem o pacote "com.adobe.air"
## -- needs com.adobe @ http://as3corelib.googlecode.com/svn/trunk/src/com/adobe/ @ revision 113
FLEX_COMPC -sp SOURCE_PATH -is SOURCE_PATH/adobe/ -o com.adobe.swc

## as3classes.amf.AMFConnection
## -- needs as3classes.amf @ http://as3classes.googlecode.com/svn/trunk/as3classes/amf @ revision 197
FLEX_COMPC -sp SOURCE_PATH -ic as3classes.amf.AMFConnection as3classes.amf.AMFConnectionEvent -o as3classes.amf.AMFConnection.swc

## caurina
## -- needs caurina @ http://tweener.googlecode.com/svn/trunk/as3/caurina @ revision 424
FLEX_COMPC -sp SOURCE_PATH -is SOURCE_PATH/caurina/ -o caurina.swc

## net.hires.debug.Stats
## --needs net.hires @ http://mrdoob.googlecode.com/svn/trunk/libs/net/hires/debug/ @ revision 144
FLEX_COMPC -sp SOURCE_PATH -ic net.hires.debug.Stats -o net.hires.debug.Stats.swc

## com.asual.swfaddress.SWFAddress
## --needs com.asual.swfaddress @ https://swfaddress.svn.sourceforge.net/svnroot/swfaddress/trunk/swfaddress/dist/as/3/com/asual/swfaddress/ @ revision 857
FLEX_COMPC -sp SOURCE_PATH -ic com.asual.swfaddress.SWFAddress -o com.asual.swfaddress.SWFAddress.swc

