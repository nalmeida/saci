/**
*
* @author igor almeida
*
* @version 1.0
*
**/
package redneck.form {

	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	import redneck.form.*;
	import redneck.form.field.*;
	import redneck.form.validation.*;
	import redneck.form.validation.validators.*
	import redneck.form.view.*;
	import redneck.form.view.selectable.*;
	import redneck.form.view.textinput.*;

	import redneck.arrange.*;
	import redneck.project.misc.*;
	
	import br.com.stimuli.string.printf;
	import redneck.util.*;
	import flash.utils.*;

	public class LayoutMyForm extends Sprite {

		public var form : Form;
		public var fields : Array;
		public var toReplace: Object;
		public function LayoutMyForm( p_toReplace:Object = null ) : void {
			super();
			fields = [];
			toReplace = p_toReplace;
		}
		
		public static function compileAllValidators():void{
			Email;
			Empty;
			EqualTo;
			GreaterThan;
			IsFalse;
			IsTrue;
			LessThan;
			MaxChars;
			MinChars;
			BetweenRange;
			MultipleEmails;
		}
		
		public static function compileAllFields():void{
			MultiViews;
			FieldView;
			CheckBox;
			TextInput;
			EmailInput;
			NumberAndAlphaInput;
			NumberInput;
			Password;
			RadioItem;
			ComboItem;
			ComboBox;
			MultipleInputs;
			MultipleChoices;
		}
		
		public function resolve ( value:String ) : *{
			if (value  && toReplace){
				value = printf( value, toReplace );
			}
			return value;
		}

		public function fromXML( p_xml : XML ) : Boolean {
			if ( !p_xml ) {return false;}

			//===========================================================
			// Form
			//===========================================================
			var f_name : String = resolve(valueFromXML( p_xml, "name" ));
			var f_url : String = resolve(valueFromXML( p_xml, "url" ));
			var f_method : String =  resolve(valueFromXML( p_xml, "method" ) || "get") ;

			// checking obligatory nodes
			if ( !f_name || !f_url || f_url.length<1 || f_name.length<1 ){return false;}

			form = new Form( f_name, f_url, f_method );

			//===========================================================
			// Fields
			//===========================================================
			if ( p_xml.hasOwnProperty("fields") && p_xml.fields.hasOwnProperty("field") ){

				var node : * = p_xml.fields;
				var numFields : int = node.field.length();
				var fieldIndex : int = 0;
				var fieldNode : *;

				while ( fieldIndex<numFields ){

					// current field node
					fieldNode = node.field[fieldIndex];
					
					// checking obligatory nodes
					var _name : String = resolve(valueFromXML(fieldNode, "name"));
					
					//===========================================================
					// Field
					//===========================================================
					if ( _name!=null && _name.length>0 ){

						var field : Field = parseField ( fieldNode, fieldIndex );
						
						if ( field ){
							form.addField( field );
						}
					}
					fieldIndex++;
				}
			}
			
			//reordering comboboxes to stay on the top.
			fields.forEach( function ( item: FieldView, ...rest ):void{
				if (item is ComboBox){
					swapChildren( item, getChildAt( numChildren-1 ) );
				}
			} )
			
			/// applying layout
			if (valueFromXML(p_xml, "orientation")){
				var orientation: int = int (valueFromXML(p_xml, "orientation"));
				var padding : Number = Number( valueFromXML(p_xml, "padding") || 0 );
				if ( orientation == FieldView.VERTICAL ){
					Arrange.toBottom( fields, {padding_y:padding} );
				}else{
					Arrange.toRight( fields, {padding_x:padding} );
				}
			}
			return true;
		}
		/**
		*	
		*	@return Field
		*	
		*	@see form_schema.xsl
		*	
		**/
		
		public function parseField( fieldNode: *, fieldIndex:int = 0) : Field {
			if (fieldNode==null){
				return null;
			}

			var _name : String = resolve(valueFromXML(fieldNode, "name"));
			var _index : int = int(valueFromXML( fieldNode, "index" ) || fieldIndex );
			var _value : * = resolve(valueFromXML( fieldNode, "value" ));
			var field : Field = new Field( _name, _index, _value );
			if ( valueFromXML( fieldNode, "onlyClient" ) ){
				field.onlyClient = Boolean(valueFromXML( fieldNode, "onlyClient" ));
			}

			// optional
			var _errorMessage : String = valueFromXML( fieldNode, "defaultErrorMessage" );
			field.defaultErrorMessage.errorMessage = _errorMessage || field.defaultErrorMessage.errorMessage;

			var _obligatory : Boolean = Boolean( valueFromXML(fieldNode, "obligatory") || false );
			field.obligatory = _obligatory;
			
			//===========================================================
			// validators
			//===========================================================
			if ( fieldNode.hasOwnProperty("validators") ){

				var numValidators : int = fieldNode.validators.validator.length( );
				var validatorIndex : int = 0;

				//===========================================================
				// validator
				//===========================================================
				while( validatorIndex<numValidators ){

					// checking validator obligatory fields
					var validatorNode : * = fieldNode.validators.validator[validatorIndex];
					var validator : AValidator = parseValidator( validatorNode );
					if (validator){
						field.addValidator( validator );
					}
					validatorIndex++;
				}
			}

			//===========================================================
			// view
			//===========================================================
			var fieldView : FieldView
			var fieldViewIndex : int = ( fields[fields.length-2] is MultipleInputs ) ? fields[fields.length-2].lastIndex : fieldIndex;
			if ( fieldNode.hasOwnProperty("view") ){
				var viewNode : * = fieldNode.view;
				fieldView = parseView(viewNode, fieldViewIndex);
			}
			
			//===========================================================
			// view multfields
			//===========================================================
			else if ( fieldNode.hasOwnProperty("multifields") ){
				var multiNode : * = fieldNode.multifields;
				fieldView = parseMultiView( multiNode, fieldViewIndex );
			}
			
			//===========================================================
			// view multiple choices
			//===========================================================
			else if ( fieldNode.hasOwnProperty("multichoices") ){
				var choicesNode : *  = fieldNode.multichoices
				fieldView = parseMultiChoices( choicesNode, fieldViewIndex );
			}
			
			if ( fieldView ){
				field.view = fieldView;
				fields.push( addChild( field.view ) );
				fieldView = null;
			}

			return field;
		}
		/**
		*	
		*	@return AValidator
		*	
		*	@see form_schema.xsl
		*	
		**/
		public function parseValidator( validatorNode:* ):AValidator{
			if (validatorNode==null){return null;}

			var v_klass: String = resolve(valueFromXML( validatorNode ,"klass" ));
			// checking obligatory nodes

			if ( v_klass==null || v_klass.length==0 ){return null;}

			try{
				// creating validator instance.
				var v_index : int = int (valueFromXML( validatorNode, "index" ) || 0 );
				var theClass: Class = getDefinitionByName( v_klass ) as Class;
				var validator : AValidator = new theClass( v_index );

				// apply extra information
				var v_error : String = valueFromXML( validatorNode, "errorMessage" );
				validator.error.errorMessage = v_error;

				if ( validatorNode.hasOwnProperty("params") ){
					var param_prop : *;
					for each( param_prop in validatorNode.params.child("*") ){
						if ( validator.hasOwnProperty(param_prop.name()) ) {
							validator[param_prop.name()] = resolve(param_prop.toString());
						}
					}
				}
				return validator;

			}catch(e:Error){
				trace("[LayoutMyForm] error creating validator instance:" + v_klass + " error: " + e.getStackTrace());
			}

			return null;
		}
		/**
		*	
		*	@return FieldView
		*	
		*	@see form_schema.xsl
		*	
		**/
		public function parseView( viewNode:*, fieldIndex:int = 0 ): FieldView {

			if (viewNode==null){return null;}

			var view_klass : String = resolve(valueFromXML( viewNode , "klass"));
			// checking obligatory nodes

			if ( view_klass==null || view_klass.length==0 ){return null;}

			var view_label : String = resolve(valueFromXML( viewNode, "label" ));
			var view_initialValue : String = resolve(valueFromXML( viewNode, "initialValue"));

			var view_index : int = int (valueFromXML( viewNode, "index" ) || fieldIndex);

			try{
				var viewClass: Class = getDefinitionByName( view_klass ) as Class;
				var fieldView : FieldView = new viewClass( view_label, view_initialValue, view_index );

				var view_ignoreInitialValue : Boolean = Boolean( valueFromXML( viewNode, "ignoreInitialValue" ) );
					fieldView.ignoreInitialValue = view_ignoreInitialValue;

				if ( valueFromXML( viewNode, "regularColor") ){
					fieldView.regularColor = int ( valueFromXML( viewNode, "regularColor") );
				}

				if ( valueFromXML( viewNode, "errorColor") ){
					fieldView.errorColor = int ( valueFromXML( viewNode, "errorColor") );
				}

				var view_orientation : int = int( valueFromXML( viewNode, "orientation") || fieldView.orientation )
					fieldView.orientation = view_orientation;

				var view_width : int = int( valueFromXML( viewNode, "fieldWidth") );
					if (view_width>0) fieldView.fieldWidth = view_width;

				var view_height : int = int( valueFromXML( viewNode, "fieldHeight") );
					if (view_height>0) fieldView.fieldHeight =  view_height;

				var view_padding : int = int( valueFromXML( viewNode, "padding") );
					fieldView.padding = view_padding;

				if ( valueFromXML( viewNode, "arrange") ){
					var n : * = valueFromXML( viewNode, "arrange");
					if (valueFromXML( n, "anchor")){
						var fAnchor : Field = form.getField( valueFromXML( n, "anchor") );
						if (fAnchor.view){
							var rules : * = valueFromXML( n, "rules");
							if (rules && rules.rule){
								var rule : *;
								var paddings : Object
								var fields : Array = [ fAnchor.view, fieldView ];
								for each( rule in rules.rule )
								{
									var type : String = valueFromXML(rule,"type");
									paddings = {
										padding_x:valueFromXML(rule,"padding_x")  || 0,
										padding_y:valueFromXML(rule,"padding_y")  || 0
									}
									if(type && Arrange[type]){
										Arrange[type]( fields, paddings )
									}
								}
							}
						}
					}
				}
				else{
					var view_x : Number = Number( valueFromXML( viewNode, "x") || 0 )
						fieldView.x = view_x;

					var view_y : Number = Number( valueFromXML( viewNode, "y") || 0 )
						fieldView.y = view_y;
				}

				return fieldView;

			}catch(e:Error){
				trace("[LayoutMyForm] error creating view instance:" + view_klass + " error: " + e.getStackTrace());
			}
			return null;
		}
		/**
		*	
		*	@param viewNode
		*	@param fieldView
		*	
		***/
		public function parseMultiView( viewNode:*, fieldIndex:int = 0 ): MultipleInputs {

			var multifields : MultipleInputs = parseView( viewNode, fieldIndex ) as MultipleInputs;

			if (multifields){
				var separator : String = resolve(String( valueFromXML( viewNode, "separator" ) || multifields.separator ));
					multifields.separator = separator;
					
				var fieldsOrientation : int = int (valueFromXML( viewNode, "fieldsOrientation" ) || multifields.fieldsOrientation );
					multifields.fieldsOrientation = fieldsOrientation;
					
				var fieldsPadding : int = int (valueFromXML( viewNode, "fieldsPadding" ) || 0 );
					multifields.fieldsPadding = fieldsPadding;

				if ( viewNode.hasOwnProperty("views") && viewNode.views.hasOwnProperty("view") ){

					var node : * = viewNode.views;
					var numFields : int = node.view.length();
					var fieldIndex : int = 0;
					var fieldNode : *;

					while ( fieldIndex<numFields ){
						var viewNode : * = node.view[fieldIndex];
						var fieldView : FieldView = parseView( viewNode , multifields.lastIndex );
						if ( fieldView ) {
							multifields.addView( fieldView );
						}
						fieldIndex++;
					}	
				}

				return multifields;
			}

			return null
		}
		/**
		*	
		*	@param viewNode
		*	@param fieldView
		*	
		***/
		public function parseMultiChoices( viewNode:*, fieldIndex:int = 0 ): MultipleChoices {

			if (viewNode){
				
				var multichoices : MultipleChoices = parseView( viewNode, fieldIndex ) as MultipleChoices;

				if (multichoices){
					var fieldsOrientation : int = int (valueFromXML( viewNode, "fieldsOrientation" ) || multichoices.fieldsOrientation );
						multichoices.fieldsOrientation = fieldsOrientation;

					var fieldsPadding : int = int (valueFromXML( viewNode, "fieldsOrientation" ) || 0 );
						multichoices.fieldsPadding = fieldsPadding;

					if ( viewNode.hasOwnProperty("options") && viewNode.options.hasOwnProperty("item") ){

						var node : * = viewNode.options;
						var numFields : int = node.item.length();
						var fieldIndex : int = 0;

						// listing options.
						try{
							while ( fieldIndex<numFields ){

								var optionNode : * = node.item[fieldIndex];
								var k  : String = resolve(valueFromXML( optionNode, "klass" ));

								// checking node consistency
								if ( k!=null && k.length>0 ){

									var viewClass: Class = getDefinitionByName( k ) as Class;
									var item : ASelectableItem = new viewClass( );

									var v : * = resolve(valueFromXML( optionNode, "value" ));
										item.value = v;

									var l : * = resolve(valueFromXML( optionNode, "label" ));
										item.label = l;

									multichoices.addOption( item )
								}
								fieldIndex++;
							}
						}catch(e:Error){
							trace("[LayoutMyForm] error creating option view instance:" + k + " error: " + e.getStackTrace());	
						}
					}
					return multichoices;
				}
				return null;
			}
			return null;
		}
	}
}
