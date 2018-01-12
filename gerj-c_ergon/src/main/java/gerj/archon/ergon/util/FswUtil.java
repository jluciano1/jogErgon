package gerj.archon.ergon.util;

import java.math.BigDecimal;

public class FswUtil {

	public static boolean isNumeric(String str) {
		try {
			Double.parseDouble(str);
		} catch (NumberFormatException nfe) {
			return false;
		}
		return true;
	}

	public Integer getInteger(Object value) {
	    
	    if(value==null)
	      return null;

	    if(value instanceof BigDecimal)
	      return ((BigDecimal)value).intValue();
	    if(value instanceof String)
	    {
	      if(((String)value).trim().equals(""))
	        return null;
	      else
	        return Integer.parseInt((String)value);
	    }
	    if(value instanceof Integer)
	      return (Integer)value;
	    if(value instanceof Byte)
	      return ((Byte)value).intValue();
	    if(value instanceof Short)
	      return ((Short)value).intValue();
	    if(value instanceof Long)
	      return ((Long)value).intValue();
	    if(value instanceof Double)
	      return ((Double)value).intValue();
	    if(value instanceof Float)
	      return ((Float)value).intValue();

	    return (Integer)value;
	  }

}


