package de.cau.cs.kieler.klighd.debug.visualization;

public class KlighdDebugField {

	public static enum FIELD {
		SELF, NEXT, NULL
	};

	private String fieldName;
	private String fieldType;
	private String relativeFieldPath;
	
	public String getFieldName() {
		return fieldName;
	}

	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}

	public String getFieldType() {
		return fieldType;
	}

	public void setFieldType(String fieldType) {
		this.fieldType = fieldType;
	}

	public String getRelativeFieldPath() {
		return relativeFieldPath;
	}

	public void setRelativeFieldPath(String relativeFieldPath) {
		this.relativeFieldPath = relativeFieldPath;
	}
	
	public KlighdDebugField(String fieldName, String fieldType,
			String relativeFieldPath) {
		this.fieldName = fieldName;
		this.fieldType = fieldType;
		this.relativeFieldPath = relativeFieldPath;
	}
	
}
