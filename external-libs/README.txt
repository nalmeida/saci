## redneck
## -- needs redneck @ http://www.ialmeida.com/projects/redneck @ revision 662
## -- needs br.com.stimuli.loading @ http://bulk-loader.googlecode.com/svn/trunk/src/br/com/stimuli/loading @ revision 319
## -- needs br.com.stimuli.string @ http://printf-as3.googlecode.com/svn/trunk/src/br/com/stimuli/string @ revision 20
## -- needs com.adobe.serialization.JSON @ http://as3corelib.googlecode.com/svn/trunk/src/com/adobe/serialization/json @ revision 113
FLEX_COMPC -sp SOURCE_PATH -is SOURCE_PATH/redneck/ -o redneck.swc

## com.adobe.serialization.json.JSON
## -- needs com.adobe.json @ http://as3corelib.googlecode.com/svn/trunk/src/com/adobe/serialization/json @ revision 113
FLEX_COMPC -sp SOURCE_PATH -ic com.adobe.serialization.json.JSON -o com.adobe.serialization.json.JSON.swc

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
## --needs com.asual.swfaddress @ https://swfaddress.svn.sourceforge.net/svnroot/swfaddress/trunk/swfaddress/dist/as/3/com/asual/swfaddress/ @ revision 834 (need to change package)
FLEX_COMPC -sp SOURCE_PATH -ic com.asual.swfaddress.SWFAddress -o com.asual.swfaddess.SWFAddress.swc

## br.com.stimuli.loading
## -- needs br.com.stimuli.loading @ http://bulk-loader.googlecode.com/svn/trunk/src/br/com/stimuli/loading @ revision 319
FLEX_COMPC -sp SOURCE_PATH -is SOURCE_PATH/br/com/stimuli/loading/ -o br.com.stimuli.loading.swc

## br.com.stimuli.string
## -- needs br.com.stimuli.string.printf @ http://printf-as3.googlecode.com/svn/trunk/src/br/com/stimuli/string @ revision 20
FLEX_COMPC -sp SOURCE_PATH -ic br.com.stimuli.string.printf -o br.com.stimuli.string.printf.swc
