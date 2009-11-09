package saci.util {
	/**
	 * @author Nicholas Almeida
	 */
	public class DateUtil{
		
		public static function getPassedTime(p_date:Date, p_lang:String = "pt-BR"):String {
			
			var lang:String = p_lang;
			var str:String;
			
			var dateFunc:Date = new Date();
			var timeSince:Number = dateFunc.getTime() - p_date.getTime();
			var inSeconds:Number = timeSince / 1000;
			var inMinutes:Number = timeSince / 1000 / 60;
			var inHours:Number = timeSince / 1000 / 60 / 60;
			var inDays:Number = timeSince / 1000 / 60 / 60 / 24;
			var inYears:Number = timeSince / 1000 / 60 / 60 / 24 / 365;

			var s:String;
			if (Math.round(inSeconds) == 1) {
				switch (lang) {
					case "pt-BR" : 
						s = " segundo atrás";
						break;
					default :
						s = " second ago";
						break;
				}
				str = 1 + s;
			}
			else if (inMinutes < 1.01) {
				switch (lang) {
					case "pt-BR" : 
						s = " segundos atrás";
						break;
					default :
						s = " seconds ago";
						break;
				}
				str = (Math.round(inSeconds) + s);
			}

			else if (Math.round(inMinutes) == 1) {
				switch (lang) {
					case "pt-BR" : 
						s = " minuto atrás";
						break;
					default :
						s = " minute ago";
						break;
				}
				str = 1 + s;
			}
			else if (inHours < 1.01) {
				switch (lang) {
					case "pt-BR" : 
						s = " minutos atrás";
						break;
					default :
						s = " minutes ago";
						break;
				}
				str = (Math.round(inMinutes) + s);
			}

			else if (Math.round(inHours) == 1) {
				switch (lang) {
					case "pt-BR" : 
						s = " hora atrás";
						break;
					default :
						s = " hour ago";
						break;
				}
				str = 1 + s;
			}
			else if (inDays < 1.01) {
				switch (lang) {
					case "pt-BR" : 
						s = " horas atrás";
						break;
					default :
						s = " hours ago";
						break;
				}
				str = (Math.round(inHours) + s);
			}

			else if (Math.round(inDays) == 1) {
				switch (lang) {
					case "pt-BR" : 
						s = " dia atrás";
						break;
					default :
						s = " dias ago";
						break;
				}
				str = 1 + s;
			}
			else if (inYears < 1.01) {
				switch (lang) {
					case "pt-BR" : 
						s = " dias atrás";
						break;
					default :
						s = " days ago";
						break;
				}
				str = Math.round(inDays) + s;
			}

			else if (Math.round(inYears) == 1) {
				switch (lang) {
					case "pt-BR" : 
						s = " ano atrás";
						break;
					default :
						s = " year ago";
						break;
				}
				str = 1 + s
			}
			else {
				switch (lang) {
					case "pt-BR" : 
						s = " anos atrás";
						break;
					default :
						s = " years ago";
						break;
				}
				str = (Math.round(inYears) + s);
			}
			
			return str;

		}
	}

}