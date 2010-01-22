<xsl:element name='form'>

	<!-- obligatory -->
	<xsl:element name='name'>String</xsl:element>
	<xsl:element name='url'>String</xsl:element>
	
	<!-- optional -->
	<xsl:element name='method'>String</xsl:element>
	<!-- 
		@see FieldView.VERTICAL, 
		@see FieldView.HORIZONTAL 
		@see Arrange
	-->
	<xsl:element name='orientation'>Number</xsl:element>
	<!-- padding x or y depending which is the current orientation -->
	<xsl:element name='padding'>Number</xsl:element>

	<xsl:element name='fields'>
		<!-- 
			@see Field  
		-->
		<xsl:element name='field'>
			<!-- obligatory -->
			<xsl:element name='name'>String</xsl:element>
			
			<!-- optional -->
			<xsl:element name='index'>int</xsl:element>
			<xsl:element name='value'>String</xsl:element>
			<xsl:element name='defaultErrorMessage'>String</xsl:element>
			<xsl:element name='obligatory'>Boolean</xsl:element>

			<!--
				@see AValidator 
			-->
			<xsl:element name='validators'>
				<xsl:element name='validator'>
					<!-- obligatory -->
					<xsl:element name='klass'>String</xsl:element>
					<!-- optional -->
					<xsl:element name='index'>int</xsl:element>
					<xsl:element name='errorMessage'>String</xsl:element>
					<xsl:element name='params'>
						<!-- 
							if your validation class has special properties to be set you can do it using 
							the node <params> and creating nodes with the property name and then the value.
							Example:
							<klass>redneck.form.validation.validators.LessThan</klass>
							<params>
								<compareValue>10</compareValue>
							</params>
							// Because LessThan has a public property called "compareValue";
						-->
						<xsl:element name='propName'>*</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- 
				@see FieldView  
			-->
			<xsl:element name='view'>
				<!-- obligatory -->
				<xsl:element name='klass'>String</xsl:element>
				<!-- optional -->
				<xsl:element name='index'>int</xsl:element>
				<!-- 
					will place this view at this x,y position
				 -->
				<xsl:element name='x'>Number</xsl:element>
				<xsl:element name='y'>Number</xsl:element>
				<xsl:element name='ignoreInitialValue'>Boolean</xsl:element>
				<xsl:element name='label'>String</xsl:element>
				<xsl:element name='initialValue'>String</xsl:element>
				<xsl:element name='regularColor'>int</xsl:element>
				<xsl:element name='errorColor'>int</xsl:element>
				<!-- 
					@see FieldView.VERTICAL, 
					@see FieldView.HORIZONTAL 
					@see Arrange
				-->
				<xsl:element name='orientation'>int</xsl:element>
				<xsl:element name='fieldWidth'>Number</xsl:element>
				<xsl:element name='fieldHeight'>Number</xsl:element>
				<xsl:element name='padding'>Number</xsl:element>
			</xsl:element>

			<!-- 
				@see MultiFieds
			-->
			<xsl:element name='multifields'>
				<!-- all "view" allowed nodes these above, optional -->
				<xsl:element name='separator'>:</xsl:element>
				<xsl:element name='fieldsOrientation'>0</xsl:element>
				<xsl:element name='fieldsPadding'>10</xsl:element>
				<xsl:element name='views'>
					<xsl:element name='view'>
						<!-- all "view" nodes -->
					</xsl:element>
				</xsl:element>
			</xsl:element>
			
		</xsl:element>
	</xsl:element>
</xsl:element>