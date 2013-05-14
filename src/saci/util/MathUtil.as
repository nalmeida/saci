package saci.util {
	
	/**
	 * Utilidades matemáticas
	 * @author Marcos Roque
	 * @since 12/07/2011 15:47
	 */
	public class MathUtil {
		
		
		/**
		 * Normaliza um angulo de 360 graus para duas metades de 180, positivo e negativo, afim de atingir aproximação mais curta de zero
		 * @param	number
		 * @return
		 */
		public static function normalizeAngle(angle:Number):Number {
			
			angle = angle - Math.floor(angle / 360) * 360;
			
			if (angle > 180)
			{
				angle-=360;
			}
			if (angle < -180)
			{
				angle+=360;
			}
			
			return angle;
		}
	}
	
}